library(tidyverse)
library(here)

#' Retorna dataframe com tipos de documentos de licitações
#' 
#' @examples 
#' tipos_documento_licitacoes <- adapta_tipos_documento_licitacoes()
#' 
adapta_tipos_documento_licitacoes <- function() {
  tipos_documento_licitacoes <- read_csv(here::here("transformer/utils/files/tipos_documentos_licitacao.csv"))
  
  return(tipos_documento_licitacoes)
}
