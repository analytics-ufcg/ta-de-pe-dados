library(tidyverse)
library(here)
library(janitor)

#' Processa dados de itens dos contratos do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos itens dos contratos
#' 
#' @return Dataframe com informações dos itens dos contratos
#' 
#' @examples 
#' itens_contrato <- import_itens_contrato(c(2017, 2018, 2019))
#' 
import_itens_contrato <- function(anos = c(2017, 2018, 2019)) {
  
  itens_contrato <- pmap_dfr(list(anos),
                              ~ import_itens_contrato_por_ano(..1)
  )
  
  return(itens_contrato)
}

#' Importa dados de itens dos contratos em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação dos itens dos contratos
#'
#' @return Dataframe com informações dos itens dos contratos
#'   
#' @examples 
#' itens_contrato <- import_itens_contrato_por_ano(2019)
#' 
import_itens_contrato_por_ano <- function(ano = 2019) {
  message(paste0("Importando itens de contrato do ano ", ano))
  itens_contrato <- read_csv(here(paste0("data/contratos/", ano, "/item_con.csv")), 
                              col_types = cols(.default = "c"))
  
  return(itens_contrato)
}
