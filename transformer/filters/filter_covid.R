#' Carrega licitações marcadas pelo TCE-RS como sendo do período da Pandemia do Covid-19
#'
#' @param anos Vector de inteiros com anos para captura das licitações
#'
#' @return Dataframe com informações das licitações relacionadas ao COVID-19. 
#' Adiciona uma coluna com o assunto covid
#'   
#' @examples 
#' licitacoes <- filter_licitacoes_covid(2019)
#' 
filter_licitacoes_covid <- function(licitacoes_df) {
  
  licitacoes_filtradas <- licitacoes_df %>% 
    dplyr::filter(BL_COVID19 == "S") %>% 
    dplyr::mutate(assunto = "covid")
  
  return(licitacoes_filtradas)
}