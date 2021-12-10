library(tidyverse)
library(futile.logger)
library(dplyr)

fetch_documentos_relacionados_federais <- function(codigo) {
  url <- str_glue("http://www.portaltransparencia.gov.br/despesas/documento/documentos-relacionados/baixar?direcaoOrdenacao=asc&codigo={codigo}&fase=Empenho")
  
  temp <- tempfile()
  dados <- tibble()
  
  tryCatch({
    download.file(url, temp)
    dados <- read_csv2(temp)
    dados <- dados %>%
      mutate(codigo_empenho_original = codigo) 
    unlink(temp)
  }, error = function(e) {
    flog.info("Não foi possível realizar o download dos dados! Verifique se o download está disponível no Portal de Transparência")
    flog.error(e)
  })
  
  return(dados)
}
