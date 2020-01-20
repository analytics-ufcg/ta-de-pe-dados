library(tidyverse)
library(here)
library(janitor)

#' Renomeia as colunas repetidas do dataframe de licitantes
#' 
#' @param licitantes Dataframe de licitantes de licitações
#' 
#' @return 
#' 
rename_duplicate_columns <- function(licitantes) {
  licitantes <- licitantes %>% 
    rename(TP_DOCUMENTO_LICITANTE = TP_DOCUMENTO,
           NR_DOCUMENTO_LICITANTE = NR_DOCUMENTO,
           TP_DOCUMENTO_REPRES = TP_DOCUMENTO_1,
           NR_DOCUMENTO_REPRES = NR_DOCUMENTO_1)
  
  return(licitantes)
}

#' Importa dados de licitantes em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação dos licitantes
#'
#' @return Dataframe com informações dos licitantes
#'   
#' @examples 
#' licitantes <- import_licitantes_por_ano(2019)
#' 
import_licitantes_por_ano <- function(ano = 2019) {
  message(paste0("Importando licitantes do ano ", ano))
  licitantes <- readr::read_csv(here(paste0("data/licitacoes/", ano, "/licitante.csv")), 
                                  col_types = cols(.default = "c", ANO_LICITACAO = "i"))
  
  return(licitantes)
}

#' Processa dados de licitantes de licitações do Rio Grande do Sul
#' 
#' @param anos Vector de inteiros com anos para captura dos licitantes
#'
#' @return Dataframe com informações dos licitantes
#'   
#' @examples 
#' licitantes <- processa_info_licitantes(c(2017, 2018, 2019, 2020))
#' 
processa_info_licitantes <- function(anos = c(2017, 2018, 2019, 2020)) {
  source(here::here("code/utils/constants.R"))
  source(here::here("code/utils/utils.R"))
  
  licitantes <- purrr::pmap_dfr(list(anos), 
                                  ~ import_licitantes_por_ano(..1)) %>% 
    rename_duplicate_columns() %>% 
    janitor::clean_names() %>% 
    generate_id("ano_licitacao", TABELA_LICITANTE, LICITANTE_ID)
  
  return(licitantes)
}
