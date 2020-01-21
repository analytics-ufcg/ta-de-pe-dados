library(tidyverse)
library(here)

#' Cria dataframe com informações dos Municípios participantes de licitações
#' 
#' @examples 
#' municipios <- processa_info_municipios()
#' 
processa_info_municipios <- function() {
  source(here("code/licitacoes/processa_licitacoes.R"))
  
  licitacoes_merenda <- import_licitacoes_merenda(anos = c(2017, 2018, 2019))
  
  info_municipios <- licitacoes_merenda %>%
    distinct(NM_ORGAO, CD_ORGAO) %>%
    rename(id_orgao = CD_ORGAO,
           nm_orgao = NM_ORGAO) %>%
    mutate(id_estado = "43", ## id do Rio Grande do Sul no IBGE
           nm_municipio = gsub("PM DE ", "", nm_orgao)) %>% 
    select(id_orgao, id_estado, nm_orgao, nm_municipio)
  
  return(info_municipios)
} 
