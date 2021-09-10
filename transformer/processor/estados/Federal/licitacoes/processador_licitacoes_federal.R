source(here::here("transformer/adapter/estados/Federal/licitacoes/adaptador_licitacoes_federal.R"))

#' Processa dados de licitações do governo Federal
#' 
#' @param filtro Filtro para aplicar para licitações federais
#' @return Dataframe com informações processadas de licitações
#' 
#' @examples 
#' licitacoes_federais <- processa_licitacoes_federal()
processa_licitacoes_federal <- function(filtro) {
  licitacoes_federais <- import_licitacoes_federal() %>% 
    adapta_info_licitacoes_federal(filtro) %>%
    add_info_estado(sigla_estado = "BR", id_estado = "99") 
  
  return(licitacoes_federais)
}
