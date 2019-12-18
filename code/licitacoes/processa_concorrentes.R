library(tidyverse)
library(here)

#' Processa dados de concorrentes de licitacões do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos concorrentes
#' 
#' @return Dataframe com informações dos concorrentes
#' 
#' @examples 
#' concorrentes <- import_concorrentes(c(2017, 2018, 2019))
#' 
import_concorrentes <- function(anos = c(2017, 2018, 2019)) {
  
  concorrentes <- pmap_dfr(list(anos),
                         ~ import_concorrentes_por_ano(..1)
  )
  
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
  concorrentes <- read_csv(here(paste0("data/licitacoes/", ano, "/licitante.csv")), col_types = cols(.default = "c"))
  
  return(concorrentes)
}

