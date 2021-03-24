source(here::here("transformer/adapter/estados/PE/orgaos/adaptador_orgaos_pe.R"))

#' Processa dados dos órgãos do estado de Pernambuco
#' 
#' @return Dataframe com informações processadas dos órgãos
#' 
#' @examples 
#' info_orgaos_pe <- processa_orgaos_pe()
processa_orgaos_pe <- function() {
  info_orgaos_pe <- import_orgaos_municipais_pe() %>%
    adapta_info_orgaos_pe(import_orgaos_estaduais_pe(), import_municipios_pe()) %>%
    add_info_estado(sigla_estado = "PE", id_estado = "26")
  
  return(info_orgaos_pe)
}