source(here::here("transformer/adapter/estados/RS/licitacoes/adaptador_licitantes_rs.R"))

#' Processa dados de licitantes do estado do Rio Grande do Sul para um conjunto de filtros
#' 
#' @param anos Vector de inteiros com anos para captura dos licitantes
#' 
#' @return Dataframe com informações processadas dos licitantes
#' 
#' @examples 
#' licitantes_rs <- processa_licitantes_rs(2019)
processa_licitantes_rs <- function(anos) {
  licitantes_rs <- import_licitantes(anos) %>%
    adapta_info_licitantes() %>% 
    add_info_estado(sigla_estado = "RS", id_estado = "43")
  
  return(licitantes_rs)
}