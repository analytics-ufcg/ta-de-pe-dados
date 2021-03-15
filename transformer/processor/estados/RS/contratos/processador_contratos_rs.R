source(here::here("transformer/adapter/estados/RS/contratos/adaptador_contratos_rs.R"))
source(here::here("transformer/adapter/estados/RS/contratos/adaptador_tipos_instrumentos_contratos_rs.R"))
source(here::here("transformer/adapter/estados/PE/contratos/adaptador_contratos_pe.R"))

#' Processa dados de contratos do estado do Rio Grande do Sul para um conjunto de filtros
#' 
#' @param anos Vector de inteiros com anos para captura dos contratos
#' 
#' @return Dataframe com informações processadas dos contratos
#' 
#' @examples 
#' contratos_rs <- processa_contratos_rs(2019)
processa_contratos_rs <- function(anos) {
  contratos_rs <- import_contratos(anos) %>%
    adapta_info_contratos()
  
  tipo_instrumento_contrato <- adapta_tipos_instrumento_contrato()
  
  contratos_rs <- join_contrato_e_instrumento(contratos_rs, tipo_instrumento_contrato) %>% 
    add_info_estado(sigla_estado = "RS", id_estado = "43")
  
  return(contratos_rs)
}