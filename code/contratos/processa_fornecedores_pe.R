source(here::here("code/utils/read_utils.R"))

#' Importa dados de fornecedores ligados a contratos do estado de Pernambuco.
#'
#' @return Dataframe com informações dos fornecedores
#'   
#' @examples 
#' fornecedores <- import_fornecedores()
#' 
import_fornecedores_pe <- function() {
  message(paste0("Importando fornecedores de Pernambuco"))
  fornecedores <- read_fornecedores_contratos_pe()
  
  return(fornecedores)
}

#' Processa dados para tabela de informações dos fornecedores no PE. Cruza com informações de quantos contratos
#' o fornecedor já possui e a data do primeiro contrato.
#' 
#' @param fornecedores_df Dataframe de fornecedores para padronização
#' 
#' @param contratos_df Dataframe com todos os contratos obtidos no TCE-PE
#'
#' @return Dataframe com informações dos fornecedores
#'   
#' @examples 
#' fornecedores <- processa_info_fornecedores_pe(fornecedores_pe_df)
#' 
#' Chave primária: 
#' (nr_documento)
processa_info_fornecedores_pe <- function(fornecedores_pe_df, contratos_pe_df, compras_pe_df) {
  
  compras_df_sem_contratos <- compras_pe_df %>% 
    dplyr::mutate(id_orgao = as.character(id_orgao)) %>% 
    dplyr::anti_join(contratos_df, 
                     by = c("id_orgao", "nr_licitacao", "ano_licitacao",
                            "cd_tipo_modalidade", "nr_contrato", "ano_contrato",
                            "tp_instrumento_contrato"))
  
  contratos_geral_df <- contratos_df %>% 
    dplyr::bind_rows(compras_df_sem_contratos)
  
  fornecedores_info_geral <- contratos_geral_df %>%
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
    dplyr::full_join(fornecedores_info_geral,
                     by = c("nr_documento" = "nr_documento_contratado")) %>% 
    dplyr::mutate(total_de_contratos = ifelse(is.na(total_de_contratos), 0, total_de_contratos)) %>% 
    dplyr::filter(!is.na(nr_documento))
  
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
    message("Warning: Existem compras de licitações (PRD e PRI) associadas a mais de um fornecedor.")
    # TODO: a relação entre compras e fornecedores deve ser 1 para n
  }

  compras_fornecedor <- compras_fornecedor_merge %>%
    dplyr::distinct(id_contrato, .keep_all = T) %>% 
    dplyr::bind_rows(compras_fornecedor_definido) %>% 
    select(-cnpj_cpf)
  
  return(compras_fornecedor)
}
