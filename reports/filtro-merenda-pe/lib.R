library(tidyverse)
library(here)
source(here("transformer/adapter/estados/PE/licitacoes/adaptador_licitacoes_pe.R"))

#' @title Gera dados de licitações prontos para a análise
#' @return Dataframe de licitações de PE com marcação se cai no filtro de merenda ou não.
process_licitacoes_filtradas_pe <- function() {
  licitacoes_pe <- import_licitacoes_pe() %>% 
    janitor::clean_names() %>% 
    select(codigo_pl, codigo_ug, nome_natureza, nome_modalidade,
           descricao_objeto, especificacao_objeto, ano_processo, 
           objeto_conforme_edital) %>% 
    distinct(codigo_pl, .keep_all = TRUE)
  
  licitacoes_merenda <- import_licitacoes_pe() %>% 
    adapta_info_licitacoes_pe(tipo_filtro = "merenda") %>% 
    select(nr_licitacao, assunto)
  
  licitacoes <- licitacoes_pe %>% 
    left_join(licitacoes_merenda, by = c("codigo_pl" = "nr_licitacao"))
  
  return(licitacoes)
}
