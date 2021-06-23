source(here::here("transformer/adapter/estados/RS/contratos/adaptador_alteracoes_contratos_rs.R"))

#' Processa dados das alterações dos contratos do estado do Rio Grande do Sul 
#' para um conjunto de filtros
#' 
#' @param anos Vector de inteiros com anos para captura das alterações dos contratos
#' 
#' @return Dataframe com informações processadas dos contratos
#' 
#' @examples 
#' alteracoes_rs <- processa_alteracoes_contratos_rs(anos)
processa_alteracoes_contratos_rs <- function(anos) {
  alteracoes_rs <- import_alteracoes_contratos(anos) %>%
    adapta_info_alteracoes_contratos() %>% 
    add_info_estado(sigla_estado = "RS", id_estado = "43")
  
  return(alteracoes_rs)
}