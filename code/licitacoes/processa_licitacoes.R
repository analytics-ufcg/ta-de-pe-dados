library(tidyverse)
library(here)

#' Processa dados de licitações do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura das licitações
#' 
#' @return Dataframe com informações das licitações
#' 
#' @examples 
#' licitacoes <- import_licitacoes(c(2017, 2018, 2019))
#' 
import_licitacoes <- function(anos = c(2017, 2018, 2019)) {
  
  licitacoes <- pmap_dfr(list(anos),
                         ~ import_licitacoes_por_ano(..1)
                         )
  
  return(licitacoes)
}

#' Importa dados de licitações em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação das licitações
#'
#' @return Dataframe com informações das licitações
#'   
#' @examples 
#' licitacoes <- import_licitacoes_por_ano(2019)
#' 
import_licitacoes_por_ano <- function(ano = 2019) {
  message(paste0("Importando licitações do ano ", ano))
  licitacoes <- read_csv(here(paste0("data/licitacoes/", ano, "/licitacao.csv")), col_types = cols(.default = "c", 
                                                                                                       VL_LICITACAO = "d"))
  
  return(licitacoes)
}

#' Carrega licitações de merenda a partir de um filtro aplicado a todas as licitações
#'
#' @param anos Vector de inteiros com anos para captura das licitações
#'
#' @return Dataframe com informações das licitações de merenda
#'   
#' @examples 
#' licitacoes_merenda <- import_licitacoes_merenda(c(2017, 2018, 2019))
#' 
import_licitacoes_merenda <- function(anos = c(2017, 2018, 2019)) {
  todas_licitacoes <- import_licitacoes(anos)
  
  licitacoes_merenda <- todas_licitacoes %>% 
    filter(CD_TIPO_MODALIDADE == "CPP",
           CD_TIPO_FASE_ATUAL == "ADH")

  return(licitacoes_merenda)
}
