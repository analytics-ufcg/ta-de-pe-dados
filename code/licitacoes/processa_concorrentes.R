library(tidyverse)
library(here)
library(janitor)

#' Renomeia as colunas repetidas do dataframe de concorrentes
#' 
#' @param concorrentes Dataframe de concorrentes de licitações
#' 
#' @return 
#' 
rename_duplicate_columns <- function(concorrentes) {
  concorrentes <- concorrentes %>% 
    rename(TP_DOCUMENTO_LICITANTE = TP_DOCUMENTO,
           NR_DOCUMENTO_LICITANTE = NR_DOCUMENTO,
           TP_DOCUMENTO_REPRES = TP_DOCUMENTO_1,
           NR_DOCUMENTO_REPRES = NR_DOCUMENTO_1)
  
  return(concorrentes)
}

#' Importa dados de concorrentes em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação dos concorrentes
#'
#' @return Dataframe com informações dos concorrentes
#'   
#' @examples 
#' concorrentes <- import_concorrentes_por_ano(2019)
#' 
import_concorrentes_por_ano <- function(ano = 2019) {
  message(paste0("Importando concorrentes do ano ", ano))
  concorrentes <- readr::read_csv(here(paste0("data/licitacoes/", ano, "/licitante.csv")), 
                                  col_types = cols(.default = "c", ANO_LICITACAO = "i"))
  
  return(concorrentes)
}

#' Processa dados de concorrentes de licitações do Rio Grande do Sul
#' 
#' @param anos Vector de inteiros com anos para captura dos concorrentes
#'
#' @return Dataframe com informações dos concorrentes
#'   
#' @examples 
#' concorrentes <- processa_info_concorrentes(c(2017, 2018, 2019, 2020))
#' 
processa_info_concorrentes <- function(anos = c(2017, 2018, 2019, 2020)) {
  source(here::here("code/utils/constants.R"))
  source(here::here("code/utils/utils.R"))
  
  concorrentes <- purrr::pmap_dfr(list(anos), 
                                  ~ import_concorrentes_por_ano(..1)) %>% 
    rename_duplicate_columns() %>% 
    janitor::clean_names() %>% 
    generate_id("ano_licitacao", TABELA_LICITANTE, LICITANTE_ID)
  
  return(concorrentes)
}
