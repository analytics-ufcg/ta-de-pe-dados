library(tidyverse)
library(here)
source(here("transformer/adapter/estados/PE/licitacoes/adaptador_licitacoes_pe.R"))
source(here::here("transformer/adapter/estados/PE/orgaos/adaptador_orgaos_pe.R"))

#' @title Gera dados de licitações prontos para a análise
#' @return Dataframe de licitações de PE com marcação se cai no filtro de merenda ou não.
process_licitacoes_filtradas_pe <- function() {
  licitacoes_pe <- import_licitacoes_pe() %>% 
    janitor::clean_names() %>% 
    select(codigo_pl, codigo_ug, ug, nome_natureza, nome_modalidade,
           descricao_objeto, especificacao_objeto, ano_processo, 
           objeto_conforme_edital) %>% 
    distinct(codigo_pl, .keep_all = TRUE)
  
  licitacoes_merenda <- import_licitacoes_pe() %>% 
    adapta_info_licitacoes_pe(tipo_filtro = "merenda") %>% 
    select(nr_licitacao, assunto)
  
  info_orgaos_pe <- import_orgaos_municipais_pe() %>%
    adapta_info_orgaos_pe(import_orgaos_estaduais_pe(), import_municipios_pe()) %>% 
    select(cd_orgao, nome_municipio)
  
  licitacoes <- licitacoes_pe %>% 
    left_join(licitacoes_merenda, by = c("codigo_pl" = "nr_licitacao")) %>% 
    left_join(info_orgaos_pe, by = c("codigo_ug" = "cd_orgao")) %>% 
    mutate(nome_municipio = if_else(is.na(nome_municipio),
                                    "Não definido",
                                    nome_municipio))
  
  return(licitacoes)
}
