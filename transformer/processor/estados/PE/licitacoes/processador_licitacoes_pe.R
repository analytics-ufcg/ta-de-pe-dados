source(here::here("transformer/adapter/estados/PE/licitacoes/adaptador_licitacoes_pe.R"))

#' Processa dados das licitações do estado de Pernambuco
#' 
#' @param filtro Filtro do assunto para licitações
#' 
#' @return Dataframe com informações processadas das licitações
#' 
#' @examples 
#' licitacoes_pe <- processa_licitacoes_pe()
processa_licitacoes_pe <- function(filtro) {
  licitacoes_pe <- import_licitacoes_pe() %>%
    adapta_info_licitacoes_pe(tipo_filtro = filtro) %>%
    add_info_estado(sigla_estado = "PE", id_estado = "26")
  
  return(licitacoes_pe)
}