source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_compras_federal.R"))
source(here::here("transformer/utils/utils.R"))

#' Processa dados dos itens das compras do governo federal
#' 
#' @param Filtro Filtro usado no processamento ('merenda' ou 'covid')
#' 
#' @return Dataframe com informações processadas dos itens das compras do Governo Federal
#' 
#' @examples 
#' itens_compras_federal <- processa_itens_compras_federal()
processa_itens_compras_federal <- function(filtro = 'covid') {
  compras_federais <- processa_compras_federal()

  itens_compras_federais <- import_itens_compras_federais() %>% 
    adapta_info_itens_compras_federal(compras_federais, filtro) %>%
    add_info_estado(sigla_estado = "BR", id_estado = "99") 

  return(itens_compras_federais)
}