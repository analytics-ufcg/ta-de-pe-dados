library(tidyverse)
library(here)

#' Cria dataframe com tipos de licitações
#' 
#' @examples 
#' tipos_licitacoes <- processa_tipos_licitacoes()
#' 
processa_tipos_instrumento_contrato <- function() {
  tipo_instrumento_contrato <- data.frame(tp_instrumento_contrato = c("A", "C", "F", "P", "R", "T", "O", "U" ),
                                          tipo_instrumento_contrato = c("Termo de adesão", "Contrato", "Termo de fomento", 
                                                                        "Termo de parceria", "Termo de credenciamento", 
                                                                        "Termo de colaboração", "Acordo de Cooperação", 
                                                                        "Termo de Permissão de Uso"),
                                          stringsAsFactors = FALSE)
  
  return(tipo_instrumento_contrato)
} 
