library(tidyverse)

#' Processa dados de pessoas envolvidas no processo licitatório no Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura das pessoas
#' 
#' @return Dataframe com informações das pessoas envolvidas no processo licitatório
#' 
#' @examples
#' pessoas_licitacao <- adapta_pessoas()
#' 
adapta_pessoas <- function(anos = c(2017, 2018, 2019)) {
  
  pessoas <- pmap_dfr(list(anos),
                      ~ import_pessoas_licitacao_por_ano(..1)
  )
  
  return(pessoas)
}

#' Importa dados de pessoas envolvidas no processo licitatório em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação das pessoas
#' 
#' @return Dataframe com informações das pessoas envolvidas no processo licitatório
#' 
#' @examples 
#' pessoas <- import_pessoas_licitacao_por_ano(2019)
#' 
import_pessoas_licitacao_por_ano <- function(ano = 2019) {
  message(paste0("Importando pessoas da licitação do ano ", ano))
  
  pessoas <- read_csv(here(paste0("data/licitacoes/", ano, "/pessoas.csv")), col_types = cols(.default = "c"))
  
  return(pessoas)
}