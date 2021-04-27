#' Carrega licitações marcadas pelo TCE-RS como sendo do período da Pandemia do Covid-19
#'
#' @param licitacoes_df Dataframe de licitações
#'
#' @return Dataframe com informações das licitações relacionadas ao COVID-19. 
#' Adiciona uma coluna com o assunto covid
#'   
#' @examples 
#' licitacoes <- filter_licitacoes_covid(import_licitacoes(2020))
#' 
filter_licitacoes_covid <- function(licitacoes_df) {
  
  licitacoes_filtradas <- licitacoes_df %>% 
    dplyr::filter(BL_COVID19 == "S") %>% 
    dplyr::mutate(assunto = "covid")
  
  return(licitacoes_filtradas)
}


#' Carrega licitações do TCE-PE relacionadas a Pandemia do COVID-19
#'
#' @param anos Vector de inteiros com anos para captura das licitações
#'
#' @return Dataframe com informações das licitações relacionadas ao COVID-19. 
#' Adiciona uma coluna com o assunto covid
#'   
#' @examples 
#' licitacoes <- filter_licitacoes_covid_pe(import_licitacoes_pe(2020))
#' 
filter_licitacoes_covid_pe <- function(licitacoes_df) {
  
  licitacoes_filtradas <- licitacoes_df %>% 
    dplyr::mutate(DS_OBJETO_PROCESSED = iconv(ObjetoConformeEdital, 
                                              from="UTF-8", 
                                              to="ASCII//TRANSLIT")) %>% 
    dplyr::mutate(
      isCompraEmergencial = grepl(
        "^.*(corona|covid|pandemia|sars-cov-2|linha de frente|testes rapidos|alcool gel).*$",
        tolower(DS_OBJETO_PROCESSED)
      )
    ) %>%
    dplyr::filter(isCompraEmergencial) %>%
    dplyr::mutate(assunto = "covid")

  return(licitacoes_filtradas)
}