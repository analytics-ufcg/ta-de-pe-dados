library(tidyverse)
library(here)
library(readxl)

#' Baixa os dados do IDEB fornecidos pelo INEP e extrai os arquivos para o 
#' diretório code/ideb/data
#' Fonte dos dados: http://portal.inep.gov.br/web/guest/educacao-basica/ideb/resultados
#' 
#' @param url URL com os dados disponibilizados pelo INEP
#' 
#' @examples 
#' fetch_ideb_por_url()
#'
fetch_ideb_por_url <- function(url = "download.inep.gov.br/educacao_basica/portal_ideb/planilhas_para_download/2017/divulgacao_anos_iniciais_municipios2017-atualizado-Jun_2019.zip") {
  
  tmp_file <- tempfile()
  download.file(url, 
                tmp_file, mode = "wb")
  
  dir.create(file.path(here("code/ideb/"), "data"), showWarnings = FALSE)
  output_path <- here("code/ideb/data")
  
  unzip(tmp_file, exdir = output_path)
  
}

#' Baixa todos os dados do IDEB (fundamental anos iniciais e finais) fornecidos pelo INEP e 
#' extrai os arquivos para o diretório code/ideb/data
#' Fonte dos dados: http://portal.inep.gov.br/web/guest/educacao-basica/ideb/resultados
#' 
#' @examples 
#' fetch_ideb_all_data()
#'
fetch_ideb_all_data <- function() {
  url_anos_iniciais <- "download.inep.gov.br/educacao_basica/portal_ideb/planilhas_para_download/2017/divulgacao_anos_iniciais_municipios2017-atualizado-Jun_2019.zip"
  
  url_anos_finais <- "download.inep.gov.br/educacao_basica/portal_ideb/planilhas_para_download/2017/divulgacao_anos_finais_municipios2017-atualizado-Jun_2019.zip"
  
  fetch_ideb_por_url(url_anos_iniciais)
  fetch_ideb_por_url(url_anos_finais)
}

#' Processa e limpa dados do IDEB disponibilizados pelo INEP. Filtra para obter dados do RS
#' Requer que os dados tenham sido baixados (é possível baixar todos os dados executando a 
#' função fetch_ideb_all_data)
#' 
#' @param data_path Caminho para o arquivo .xlsx com os dados do IDEB
#' 
#' @return Dados do IDEB para municípios do RS
#' 
#' @examples 
#' ideb <- process_ideb()
#'
process_ideb <- function(data_path = here::here("code/ideb/data/divulgacao_anos_iniciais_municipios2017-atualizado-Jun_2019.xlsx")) {
  
  ideb_raw <- read_excel(data_path) %>% 
    select(uf = ...1, cod_municipio = `Ministério da Educação`, 
           municipio = ...3, tipo = ...4, ...75:...81)
 
  ideb_rs <- ideb_raw %>% 
    filter(uf == "RS")
  
  colnames(ideb_rs) <- c("uf", "cod_municipio", "municipio", "tipo",
                         "ideb_2005", "ideb_2007", "ideb_2009",
                         "ideb_2011", "ideb_2013", "ideb_2015", "ideb_2017")
  
  return(ideb_rs)
}

#' Processa e limpa todos os dados do IDEB (séries iniciais e finais do ensino fundamental e 
#' o ensino médio) disponibilizados pelo INEP. Filtra para obter dados do RS
#'
#' Requer que os dados tenham sido baixados (é possível baixar todos os dados executando a 
#' função fetch_ideb_all_data)
#' 
#' @param remover_data TRUE se após o processamento dos dados o diretório data deve ser removido. FALSE caso contrário
#' 
#' @return Dados do IDEB para municípios do RS em todos os níveis escolares
#' 
#' @examples 
#' ideb_rs <- process_ideb_all_data()
#'
process_ideb_all_data <- function(remover_data = TRUE) {
  fundamental_anos_iniciais <- here("code/ideb/data/divulgacao_anos_iniciais_municipios2017-atualizado-Jun_2019.xlsx")
  fundamental_anos_finais <- here("code/ideb/data/divulgacao_anos_finais_municipios2017-atualizado-Jun_2019.xlsx")

  ideb_anos_iniciais <- process_ideb(fundamental_anos_iniciais) %>% 
    mutate(periodo = "fundamental anos iniciais")
  
  ideb_anos_finais <- process_ideb(fundamental_anos_finais) %>% 
    mutate(periodo = "fundamental anos finais")

  ideb_all <- ideb_anos_iniciais %>% 
    rbind(ideb_anos_finais) %>% 
    select(periodo, dplyr::everything())
  
  if(remover_data) {
    unlink(here("code/ideb/data"), recursive = T, force = T)
  }

  return(ideb_all)
}
