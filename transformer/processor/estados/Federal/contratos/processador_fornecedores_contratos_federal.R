source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_fornecedores_contratos_federal.R"))

#' Processa dados dos fornecedores das compras/contratos do Governo Federal
#' 
#' @param contratos_federal Dataframe das compras/contratos do Governo Federal
#' 
#' @return Dataframe com informações processadas dos fornecedores
#' 
#' @examples 
#' fornecedores_contratos_federal <- processa_fornecedores_contratos_federal()
processa_fornecedores_contratos_federal <- function(contratos_federal) {
  fornecedores_contratos_federal <- import_fornecedores_federal() %>%
    adapta_info_fornecedores_federal(contratos_federal) %>%
    add_info_estado(sigla_estado = "FE", id_estado = "99")
  
  return(fornecedores_contratos_federal)
}
