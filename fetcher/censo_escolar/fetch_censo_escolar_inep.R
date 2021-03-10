library(tidyverse)
library(here)
library(readxl)
source(here("fetcher/censo_escolar/colunas_constants.R"))

#' Recupera e realiza o processo de limpeza dos dados do censo escolar fornecidos pelo INEP
#' Fonte dos dados: http://portal.inep.gov.br/artigo/-/asset_publisher/B4AQV9zFY7Bv/content/dados-finais-do-censo-escolar-2018-sao-publicados-no-diario-oficial-da-uniao/21206
#' 
#' @param url URL com os dados disponibilizados pelo INEP
#' 
#' @return Dataframe com o censo escolar
#' 
#' @examples 
#' censo_escolar <- fetch_censo_escolar_por_url()
#' 
fetch_censo_escolar_por_url <- function(url = "http://download.inep.gov.br/educacao_basica/censo_escolar/resultado/2018/2018_final_anexo_I.xlsx") {
  tmp_file <- tempfile()
  download.file(url, 
                tmp_file, mode = "wb")
  
  censo_ensino_regular <- read_excel(tmp_file)
  
  colnames(censo_ensino_regular) <- .COLUNAS_CENSO_ESCOLAR
  
  uf_interesse <- "RIO GRANDE DO SUL"
  uf_sucessora <- "RONDONIA" ## próxima UF na ordem alfabética
  
  censo_rs <- censo_ensino_regular %>% 
    mutate(flag  = +(row_number() %in% which(entidade == uf_interesse):which(entidade == uf_sucessora))) %>% 
    filter(flag == 1, entidade != uf_sucessora) %>% 
    select(-flag)
  
  censo_rs_alt <- censo_rs %>% 
    mutate(municipio = ifelse(entidade == toupper(entidade), entidade, NA_character_)) %>% 
    select(municipio, dplyr::everything()) %>% 
    fill(municipio) %>% 
    filter(municipio != uf_interesse,
           !is.na(creche_parcial)) %>% 
    rename(esfera = entidade)
    
  return(censo_rs_alt)
}

#' Processa os dados de censo escolar disponibilizados pelo INEP
#' Fonte dos dados: http://portal.inep.gov.br/artigo/-/asset_publisher/B4AQV9zFY7Bv/content/dados-finais-do-censo-escolar-2018-sao-publicados-no-diario-oficial-da-uniao/21206
#' 
#' @return Dataframe com o censo escolar (ensino regular e educação especial)
#' 
#' @examples 
#' censo_escolar_rs <- fetch_censo_escolar_all()
#' 
fetch_censo_escolar_all <- function() {
  url_ensino_regular <- paste0("http://download.inep.gov.br/educacao_basica/censo_escolar/resultado/2018/2018_final_anexo_I.xlsx")
    
  url_educacao_especial <- "http://download.inep.gov.br/educacao_basica/censo_escolar/resultado/2018/2018_final_anexo_II.xlsx"
  
  ensino_regular <- fetch_censo_escolar_por_url(url_ensino_regular) %>% 
    mutate(tipo_educacao = "regular")
  
  educacao_especial <- fetch_censo_escolar_por_url(url_educacao_especial) %>% 
    mutate(tipo_educacao = "especial")
  
  dados_censo_escolar <- ensino_regular %>% 
    rbind(educacao_especial) %>% 
    select(tipo_educacao, dplyr::everything())
  
  return(dados_censo_escolar)
}
