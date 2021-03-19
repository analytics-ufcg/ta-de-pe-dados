source(here::here("transformer/adapter/estados/PE/contratos/adaptador_fornecedores_contratos_pe.R"))

#' Processa dados dos fornecedores dos contratos do estado de Pernambuco
#' 
#' @param contratos_pe Dataframe de contratos de Pernambuco
#' 
#' @return Dataframe com informações processadas dos fornecedores
#' 
#' @examples 
#' fornecedores_contratos_pe <- processa_fornecedores_contratos_pe()
processa_fornecedores_contratos_pe <- function(contratos_pe) {
  fornecedores_contratos_pe <- import_fornecedores_pe() %>%
    adapta_info_fornecedores_pe(contratos_pe) %>%
    add_info_estado(sigla_estado = "PE", id_estado = "26")
  
  return(fornecedores_contratos_pe)
}