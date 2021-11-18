library(tidyverse)
library(futile.logger)

fetch_documentos_relacionados <- function(codigo) {
  url <- str_glue("http://www.portaltransparencia.gov.br/despesas/documento/documentos-relacionados/baixar?direcaoOrdenacao=asc&codigo={codigo}&fase=Empenho")
  
  temp <- tempfile()
  dados <- tibble()
  
  tryCatch({
    download.file(url, temp)
    dados <- read_csv2(temp)
    unlink(temp)
  }, error = function(e) {
    flog.info("Não foi possível realizar o download dos dados! Verifique se o download está disponível no Portal de Transparência")
    flog.error(e)
  })
  
  return(dados)
}

