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
processa_itens_compras_federal <- function(empenhos_licitacao_df, filtro = 'covid') {
  empenhos_relacionados <- import_empenhos_licitacao_federal() %>% adapta_info_compras_federal(empenhos_licitacao_df, filtro)

  itens_compras_federais <- import_itens_compras_federais() %>% 
    adapta_info_itens_compras_federal(empenhos_relacionados, filtro) %>%
    add_info_estado(sigla_estado = "BR", id_estado = "99") 

  return(itens_compras_federais)
}