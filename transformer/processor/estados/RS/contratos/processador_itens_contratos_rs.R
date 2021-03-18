source(here("transformer/adapter/estados/RS/contratos/adaptador_itens_contratos_rs.R"))

#' Processa dados dos itens dos contratos do estado do Rio Grande do Sul 
#' para um conjunto de filtros
#' 
#' @param anos Vector de inteiros com anos para captura dos itens
#' 
#' @return Dataframe com informações processadas dos itens
#' 
#' @examples 
#' itens_contrato <- processa_itens_contrato_rs(2019)
processa_itens_contrato_rs <- function(anos) {
  itens_contrato <- import_itens_contrato(anos)
  
  return(itens_contrato)
}

#' Processa dados de itens de contratos com colunas renomeadas do estado do Rio Grande do Sul
#' 
#' @return Dataframe com informações processadas dos itens de contratos
#' 
#' @examples 
#' itens_contrato <- processa_itens_contratos_renamed_columns_rs()
processa_itens_contratos_renamed_columns_rs <- function() {
  itens_contrato <- itens_contrato %>%
    dplyr::mutate(ORIGEM_VALOR = "contrato")
  
  return(itens_contrato)
}

#' Processa dados de todos os itens comprados do estado do Rio Grande do Sul
#' 
#' @return Dataframe com informações processadas ositens comprados
#' 
#' @examples 
#' itens_contratos_rs <- processa_todos_itens_comprados(itens_comprados)
processa_todos_itens_comprados <- function(itens_comprados, itens_licitacoes) {
  itens_contratos_rs <- itens_comprados %>%
    adapta_info_item_contrato(itens_licitacoes) %>% 
    add_info_estado(sigla_estado = "RS", id_estado = "43")
  
  return(itens_contratos_rs)
}


