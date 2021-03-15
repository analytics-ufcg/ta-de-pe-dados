source(here::here("transformer/adapter/estados/RS/licitacoes/adaptador_itens_licitacoes_rs.R"))

#' Processa dados de itens/produtos de licitantes do estado do Rio Grande do Sul 
#' para um conjunto de filtros.
#' 
#' @param anos Vector de inteiros com anos para captura dos itens
#' 
#' @return Dataframe com informações processadas dos itens
#' 
#' @examples 
#' itens_licitacao_rs <- processa_itens_licitacoes_rs(2019)
processa_itens_licitacoes_rs <- function(anos) {
  itens_licitacao_raw <- import_itens_licitacao(anos)
  
  itens_licitacao_rs <- itens_licitacao_raw %>%
    adapta_info_item_licitacao() %>% 
    add_info_estado(sigla_estado = "RS", id_estado = "43")
  
  return(itens_licitacao_rs)
}

#' Processa e altera colunas de dados de itens/produtos de licitantes do estado do Rio Grande do Sul.
#' 
#' @return Dataframe com informações dos itens
#' 
#' @examples 
#' itens_licitacao <- processa_itens_licitacoes_renamed_columns_rs(2019)
processa_itens_licitacoes_renamed_columns_rs <- function() {
  itens_licitacao_raw <- import_itens_licitacao(anos)
  itens_licitacao <- itens_licitacao_raw %>%
    rename_duplicate_columns()
  
  return(itens_licitacao)
}

#' Processa dados de itens/produtos de licitantes do estado do Rio Grande do Sul 
#' para um conjunto de filtros.
#' 
#' @param anos Vector de inteiros com anos para captura dos itens
#' 
#' @return Dataframe com informações processadas dos itens
#' 
#' @examples 
#' itens_comprados <- processa_item_licitacao_comprados_rs(anos, compras_rs, itens_contrato)
processa_item_licitacao_comprados_rs <- function(anos, compras_rs, itens_contrato) {
  itens_licitacao_raw <- import_itens_licitacao(anos)
  
  itens_licitacao <- itens_licitacao_raw %>%
    adapta_item_licitacao_comprado(compras_rs)
  
  intersecao <- Reduce(dplyr::intersect, list(names(itens_contrato), names(itens_licitacao)))
  
  itens_comprados <- itens_licitacao %>%
    dplyr::select(all_of(intersecao)) %>%
    dplyr::bind_rows(itens_contrato) %>% 
    distinct()
  
  return (itens_comprados)
}