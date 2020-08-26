source(here::here("code/utils/read_utils.R"))

#' Processa dados de fornecedores ligados a contratos do estado do Rio Grande do Sul 
#' para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos fornecedores
#' 
#' @return Dataframe com informações dos fornecedores
#' 
#' @examples 
#' fornecedores <- import_fornecedores(c(2018, 2019, 2020))
#' 
import_fornecedores <- function(anos = c(2018, 2019, 2020)) {
  
  fornecedores <- purrr::pmap_dfr(list(anos),
                               ~ import_fornecedores_por_ano(..1)
  )
  
  return(fornecedores)
}

#' Importa dados de fornecedores ligados a contratos em um ano específico para o 
#' estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação dos fornecedores dos contratos
#'
#' @return Dataframe com informações dos fornecedores
#'   
#' @examples 
#' fornecedores <- import_fornecedores_por_ano()
#' 
import_fornecedores_por_ano <- function(ano = 2019) {
  message(paste0("Importando fornecedores do ano ", ano))
  fornecedores <- read_fornecedores_contratos(ano)
  
  return(fornecedores)
}

#' Processa dados para tabela de informações dos fornecedores no RS. Cruza com informações de quantos contratos
#' o fornecedor já possui e a data do primeiro contrato.
#' 
#' @param fornecedores_df Dataframe de fornecedores para padronização
#' 
#' @param contratos_df Dataframe com todos os contratos obtidos no TCE-RS
#'
#' @return Dataframe com informações dos fornecedores
#'   
#' @examples 
#' fornecedores <- processa_info_fornecedores(fornecedores_df)
#' 
#' Chave primária: 
#' (nr_documento)
processa_info_fornecedores <- function(fornecedores_df, contratos_df) {
  
  fornecedores_info_geral <- contratos_df %>%
    dplyr::group_by(nr_documento_contratado) %>%
    dplyr::summarise(
      total_de_contratos = dplyr::n_distinct(
        nr_contrato,
        ano_contrato,
        id_orgao,
        nr_licitacao,
        ano_licitacao,
        cd_tipo_modalidade,
        tp_instrumento_contrato
      ),
      data_primeiro_contrato = min(dt_inicio_vigencia, na.rm = TRUE)
    ) %>% 
    dplyr::ungroup()
  
  info_fornecedores <- fornecedores_df %>%
    janitor::clean_names() %>% 
    dplyr::arrange(nm_pessoa) %>% 
    dplyr::group_by(nr_documento) %>% 
    dplyr::summarise(nm_pessoa = dplyr::first(nm_pessoa),
                     tp_pessoa = dplyr::first(tp_pessoa)) %>% 
    dplyr::ungroup() %>% 
    ## Cruza com informações do fornecedor
    dplyr::left_join(fornecedores_info_geral,
                     by = c("nr_documento" = "nr_documento_contratado")) %>% 
    dplyr::mutate(total_de_contratos = ifelse(is.na(total_de_contratos), 0, total_de_contratos))
  
  return(info_fornecedores)
}

#' Associa os fornecedores a compras realizadas em licitações que geraram empenhos mas que dispensaram
#' o contrato
#' 
#' @param empenhos_df Dataframe de empenhos
#' 
#' @param compras_df Dataframe de compras (contratos e compras que dispensaram o contrato)
#'
#' @return Dataframe dos contratos e os fornecedores preenchidos.
#'   
#' @examples 
#' contratos_com_todos_fornecedores <- processa_fornecedores_compras(empenhos_df, compras_df)
#' 
#' Chave primária: 
#' (nr_documento)
empenhos_df <- read_empenhos_processados()
compras_df <- read_contratos_processados() %>% 
  mutate(bak = nr_documento_contratado)

processa_fornecedores_compras <- function(empenhos_df, compras_df) {
  
  fornecedores_empenhos <- empenhos_df %>% 
    dplyr::mutate(cnpj_cpf = 
             dplyr::case_when(
               tp_pessoa == "PF" ~ str_pad(cnpj_cpf, 11, side = "left", pad = "0"),
               tp_pessoa == "PJ" ~ str_pad(cnpj_cpf, 14, side = "left", pad = "0"),
               T ~ cnpj_cpf)) %>% 
    dplyr::group_by(cnpj_cpf, id_licitacao) %>% 
    dplyr::summarise(n_operacoes = n_distinct(id_empenho)) %>% 
    dplyr::ungroup()
  
  ## remover teste abaixo
  compras_df <- compras_df %>%
    rowwise() %>% 
    mutate(nr_documento_contratado = ifelse(runif(1, 0, 1) > 0.5, nr_documento_contratado, NA))
  ## remover teste acima
  
  compras_fornecedor_definido <- compras_df %>% 
    dplyr::filter(!is.na(nr_documento_contratado) | !(cd_tipo_modalidade %in% c("PRD", "PRI")))
  
  compras_fornecedor_indefinido <- compras_df %>% 
    dplyr::filter(is.na(nr_documento_contratado),
                  cd_tipo_modalidade %in% c("PRD", "PRI"))
  
  compras_fornecedor_merge <- compras_fornecedor_indefinido %>% 
    dplyr::left_join(fornecedores_empenhos %>% 
                       dplyr::select(cnpj_cpf, id_licitacao), 
                     by = c("id_licitacao")) %>% 
    dplyr::mutate(nr_documento_contratado = dplyr::if_else(is.na(nr_documento_contratado),
                                                           cnpj_cpf,
                                                           nr_documento_contratado))
  
  if (nrow(compras_fornecedor_merge) != nrow(compras_fornecedor_indefinido)) {
    message("Existem compras de licitações (PRD e PRI) associadas a mais de um fornecedor.")
  }

  compras_fornecedor <- compras_fornecedor_merge %>%
    dplyr::distinct(id_contrato, .keep_all = T) %>% 
    dplyr::bind_rows(compras_fornecedor_definido)
  
  return(compras_fornecedor)
}
