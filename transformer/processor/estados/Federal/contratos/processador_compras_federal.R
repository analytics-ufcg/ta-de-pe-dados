source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_compras_federal.R"))
source(here::here("transformer/utils/utils.R"))

#' Processa dados das compras do governo federal
#' 
#' @return Dataframe com informações processadas das compras do Governo Federal
#' 
#' @examples 
#' compras_federal <- processa_compras_federal()
processa_compras_federal <- function() {
  empenhos_relacionados <- import_empenhos_licitacao_federal()

  compras_federais <- import_empenhos_federal() %>% 
    adapta_info_compras_federal(empenhos_relacionados) %>%
    add_info_estado(sigla_estado = "FE", id_estado = "99") 
  
  return(compras_federais)
}
