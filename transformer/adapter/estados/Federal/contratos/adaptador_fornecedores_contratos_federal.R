source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_compras_federal.R"))

#' Importa dados de fornecedores ligados a compras (empenhos) no Governo Federal
#'
#' @return Dataframe com informações dos fornecedores
#'   
#' @examples 
#' fornecedores <- import_fornecedores_federal()
#' 
import_fornecedores_federal <- function() {
  message(paste0("Importando fornecedores do Governo Federal"))
  fornecedores <- import_empenhos_federal()
  
  return(fornecedores)
}

#' Processa dados para tabela de informações dos fornecedores no Governo Federal. 
#' Cruza com informações de quantas compras o fornecedor já possui e a data do primeiro contrato.
#' 
#' @param fornecedores_df Dataframe de fornecedores para padronização
#' 
#' @param contratos_df Dataframe com todos as compras obtidas no Governo Federal
#'
#' @return Dataframe com informações dos fornecedores
#'   
#' @examples 
#' fornecedores <- adapta_info_fornecedores_federal(fornecedores_df, contratos_df)
#' 
#' Chave primária: 
#' (nr_documento)
adapta_info_fornecedores_federal <- function(fornecedores_df, contratos_df) {
  fornecedores_info_geral <- contratos_df %>%
    dplyr::group_by(nr_documento_contratado) %>%
    dplyr::summarise(
      total_de_contratos = dplyr::n_distinct(
        codigo_contrato,
        cd_orgao
      ),
      data_primeiro_contrato = min(dt_inicio_vigencia, na.rm = TRUE)
    ) %>% 
    dplyr::ungroup()
  
  info_fornecedores <- fornecedores_df %>%
    janitor::clean_names() %>% 
    dplyr::mutate(codigo_favorecido = str_replace_all(codigo_favorecido, "[[.-]]", "")) %>% 
    dplyr::mutate(tp_documento_contratado = case_when(
      nchar(codigo_favorecido) == 11 ~ 'F',
      nchar(codigo_favorecido) == 14 ~ 'J',
      TRUE ~ 'O'
    )) %>%
    dplyr::select(nr_documento = codigo_favorecido, nm_pessoa = favorecido, tp_pessoa = tp_documento_contratado) %>%
    dplyr::arrange(nm_pessoa) %>% 
    dplyr::group_by(nr_documento) %>% 
    dplyr::summarise(nm_pessoa = dplyr::first(nm_pessoa),
                     tp_pessoa = dplyr::first(tp_pessoa)) %>% 
    dplyr::ungroup() %>% 
    ## Cruza com informações do fornecedor
    dplyr::right_join(fornecedores_info_geral,
                     by = c("nr_documento" = "nr_documento_contratado")) %>% 
    dplyr::mutate(total_de_contratos = ifelse(is.na(total_de_contratos), 0, total_de_contratos)) %>%
    dplyr::filter(!is.na(nr_documento))
  
  return(info_fornecedores)
}
