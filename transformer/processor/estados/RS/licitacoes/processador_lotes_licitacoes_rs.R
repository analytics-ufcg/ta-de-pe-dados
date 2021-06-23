source(here("transformer/adapter/estados/RS/licitacoes/adaptador_lotes_licitacoes_rs.R"))

#' Processa dados dos lotes das licitações do estado do Rio Grande do Sul 
#' para um conjunto de filtros
#' 
#' @param anos Vector de inteiros com anos para captura dos lotes das licitações
#' 
#' @return Dataframe com informações processadas dos lotes
#' 
#' @examples 
#' lotes_licitacoes_rs <- processa_lotes_licitacoes_rs(2019)
processa_lotes_licitacoes_rs <- function(anos) {
  lotes_licitacoes_rs <- import_lotes_licitacao(anos) %>%
    adapta_info_lote_licitacao() %>% 
    add_info_estado(sigla_estado = "RS", id_estado = "43")
  
  return(lotes_licitacoes_rs)
}