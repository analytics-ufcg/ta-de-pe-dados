source(here::here("transformer/adapter/estados/RS/orgaos/adaptador_orgaos_rs.R"))

#' Processa dados dos órgãos do estado do Rio Grande do Sul para um conjunto de filtros
#' 
#' @param anos Vector de inteiros com anos para captura dos órgãos
#' @param filtro Pode ser merenda ou covid
#' 
#' @return Dataframe com informações processadas dos órgãos
#' 
#' @examples 
#' info_orgaos_rs <- processador_orgaos_rs(2019, "covid")
processa_orgaos_rs <- function(anos, filtro) {
  info_orgaos_rs <- import_orgaos() %>%
    adapta_info_orgaos(import_licitacoes(anos) %>%
                         adapta_info_licitacoes(tipo_filtro = filtro)) %>% 
    add_info_estado(sigla_estado = "RS", id_estado = "43")
  
  return(info_orgaos_rs)
}