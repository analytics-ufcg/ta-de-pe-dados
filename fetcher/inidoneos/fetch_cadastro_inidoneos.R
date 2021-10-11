library(tidyverse)
library(futile.logger)


#' @title Recupera tabela mais atual do CEIS (Cadastro Nacional de Empresas Inidôneas e Suspensas)
#' @description Acessa os dados abertos do portal de transparência para baixar e extrair os dados do CEIS
#' @param data_atual String com a data atual no formato: YYYYMMDD
#' @return Dataframe com os dados atuais do CEIS. 
#' Retorna um dataframe vazio se não tiver sido possível realizar o download.
fetch_ceis <- function(data_atual) {
  url <- str_glue("http://www.portaltransparencia.gov.br/download-de-dados/ceis/{data_atual}")
  
  temp <- tempfile()
  dados <- tibble()

  tryCatch({
    download.file(url, temp)
    dados <- read_csv2(unz(temp, str_glue("{data_atual}_CEIS.csv")), locale = locale(encoding = 'ISO-8859-1'))
    unlink(temp)
  }, error = function(e) {
    flog.info("Não foi possível realizar o download dos dados do CEIS! Verifique se o download está disponível no Portal de Transparência")
    flog.error(e)
  })
  
  return(dados)
}

#' @title Recupera tabela mais atual do CEIS (Cadastro Nacional de Empresas Inidôneas e Suspensas) diretamente do github
#' @return Dataframe com os dados atuais do CEIS.
fetch_ceis_github <- function(data_atual) {
  tryCatch({
    # Solução temporária enquanto o problema na Azure não é resolvido
    url <- "https://raw.githubusercontent.com/analytics-ufcg/ta-de-pe-dados/master/data/inidoneos/ceis.csv"
    dados <- read_csv(url)
  }, error = function(e) {
    flog.info("Não foi possível realizar o download dos dados do CEIS! Verifique se o download está disponível no Github")
    flog.error(e)
  })
  
  return(dados)
}

#' @title Recupera tabela mais atual do CNEP (Cadastro Nacional das Empresas Punidas)
#' @description Acessa os dados abertos do portal de transparência para baixar e extrair os dados do CNEP
#' @param data_atual String com a data atual no formato: YYYYMMDD
#' @return Dataframe com os dados atuais do CNEP 
#' Retorna um dataframe vazio se não tiver sido possível realizar o download.
fetch_cnep <- function(data_atual) {
  url <- str_glue("http://www.portaltransparencia.gov.br/download-de-dados/cnep/{data_atual}")
  
  temp <- tempfile()
  dados <- tibble()
  
  tryCatch({
    download.file(url, temp)
    dados <- read_csv2(unz(temp, str_glue("{data_atual}_CNEP.csv")), locale = locale(encoding = 'ISO-8859-1'))
    unlink(temp)
  }, error = function(e) {
    flog.info("Não foi possível realizar o download dos dados do CNEP! Verifique se o download está disponível no Portal de Transparência")
    flog.error(e)
  })
  
  return(dados)
}

#' @title Recupera tabela mais atual do CNEP (Cadastro Nacional das Empresas Punidas) diretamente do github
#' @return Dataframe com os dados atuais do CNEP.
fetch_cnep_github <- function(data_atual) {
  tryCatch({
    # Solução temporária enquanto o problema na Azure não é resolvido
    url <- "https://raw.githubusercontent.com/analytics-ufcg/ta-de-pe-dados/master/data/inidoneos/cnep.csv"
    dados <- read_csv(url)
  }, error = function(e) {
    flog.info("Não foi possível realizar o download dos dados do CEIS! Verifique se o download está disponível no Github")
    flog.error(e)
  })
  
  return(dados)
}
