source(here("transformer/adapter/estados/RS/licitacoes/adaptador_eventos_licitacoes_rs.R"))

#' Processa dados de eventos de licitação do estado do Rio Grande do Sul para um 
#' conjunto de filtros
#' 
#' @param anos Vector de inteiros com anos para captura dos eventos das licitações
#' 
#' @return Dataframe com informações processadas dos eventos das licitações
#' 
#' @examples 
#' licitacoes_encerradas_rs <- processa_eventos_licitacoes_rs(2019)
processa_eventos_licitacoes_rs <- function(anos) {
  licitacoes_encerradas_rs <- import_eventos_licitacoes(anos) %>%
    filtra_licitacoes_encerradas() %>%
    dplyr::mutate(data_evento = as.POSIXct(data_evento, format="%Y-%m-%d")) %>%
    dplyr::mutate(dt_inicio_vigencia = data_evento)
  
  return(licitacoes_encerradas_rs)
}