source(here::here("transformer/adapter/estados/Federal/orgaos/adaptador_orgaos_federal.R"))

#' Processa dados dos órgãos do governo Federal
#' 
#' @return Dataframe com informações processadas dos órgãos
#' 
#' @examples 
#' orgaos_federais <- processa_orgaos_federal()
processa_orgaos_federal <- function() {
  orgaos_federais <- import_orgaos_federal() %>% 
    adapta_info_orgaos_federal() %>%
    add_info_estado(sigla_estado = "FE", id_estado = "99") 
  
  return(orgaos_federais)
}
