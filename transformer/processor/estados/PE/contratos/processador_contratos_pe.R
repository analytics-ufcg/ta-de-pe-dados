source(here::here("transformer/adapter/estados/PE/contratos/adaptador_contratos_pe.R"))

#' Processa dados dos contratos do estado de Pernambuco
#' 
#' @return Dataframe com informações processadas dos contratos
#' 
#' @examples 
#' contratos_pe <- processa_contratos_pe()
processa_contratos_pe <- function() {
  contratos_pe <- import_contratos_pe() %>% 
    adapta_info_contratos_pe() %>%
    add_info_estado(sigla_estado = "PE", id_estado = "26") 
  
  return(contratos_pe)
}