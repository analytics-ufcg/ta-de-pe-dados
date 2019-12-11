library(tidyverse)

#' Processa participantes das licitações (licitantes) no Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos licitantes
#' 
#' @return Dataframe com informações dos licitantes
#' 
#' @examples
#' licitantes_rs <- processa_licitantes()
#' 
processa_licitantes <- function(anos = c(2017, 2018, 2019)) {
  
  licitantes <- pmap_dfr(list(anos),
                         ~ import_licitantes_por_ano(..1)
  )
  
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
  
  licitantes <- read_csv(here(paste0("data/licitacoes/", ano, "/licitante.csv")), col_types = cols(.default = "c"))
  
  return(licitantes)
}