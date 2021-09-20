library(tidyverse)
source(here::here("transformer/utils/read/read_empenhos_federais.R"))
source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_compras_federal.R"))
library(futile.logger)

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


#' Carrega licitações relacionadas a empenhos filtrados por COVID para as Compras do Governo Federal
#'
#' @param licitacoes_df Dataframe de licitações
#'
#' @return Dataframe com informações das licitações relacionadas ao COVID-19. 
#' Adiciona uma coluna com o assunto covid
#'   
#' @examples 
#' licitacoes <- filter_licitacoes_covid(import_licitacoes(2020))
#' 
filter_licitacoes_federais_covid <- function(licitacoes_df) {
  empenhos_covid <- import_empenhos_federal()
  empenhos_licitacoes_df <- import_empenhos_licitacao_federal()
  
  empenhos_covid_filtrados <- empenhos_licitacoes_df %>% 
    distinct(codigo_empenho, numero_licitacao, codigo_ug, codigo_modalidade_compra, .keep_all = TRUE) %>% 
    mutate(codigo_modalidade_compra = as.character(codigo_modalidade_compra), 
           codigo_ug = as.character(codigo_ug)) %>% 
    select(codigo_empenho,
           numero_licitacao,
           codigo_modalidade_compra,
           codigo_ug) %>% ## na tabela que relaciona empenhos a licitações o codigo_ug é o código da unidade gestora da licitação
    inner_join(empenhos_covid %>% select(codigo), by = c("codigo_empenho" = "codigo"))
  
  flog.info(str_glue("Foram encontradas {empenhos_covid %>% nrow()} notas de empenho relacionadas a COVID."))
  flog.info(str_glue("{empenhos_covid_filtrados %>% nrow()} dessas notas de empenho estão relacionadas a alguma licitação."))
  
  licitacoes_filtradas <- licitacoes_df %>% 
    inner_join(empenhos_covid_filtrados %>% 
                 distinct(numero_licitacao, codigo_modalidade_compra, codigo_ug),
               by = c("numero_licitacao", "codigo_modalidade_compra", "codigo_ug"))
  flog.info(str_glue("Foram encontradas {licitacoes_df %>% nrow()} licitações no Governo Federal para qualquer assunto."))
  flog.info(str_glue("{licitacoes_filtradas %>% nrow()} dessas licitações estão relacionadas a COVID."))
  
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
  
  FUNDAMENTO_LEGAL_COMPRAS_EMERGENCIAIS <- c(79, 80)

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
    dplyr::filter(AnoProcesso >= 2020) %>% 
    dplyr::filter(isCompraEmergencial | (FundamentoLegal %in% FUNDAMENTO_LEGAL_COMPRAS_EMERGENCIAIS)) %>%
    dplyr::mutate(assunto = "covid")

  return(licitacoes_filtradas)
}
