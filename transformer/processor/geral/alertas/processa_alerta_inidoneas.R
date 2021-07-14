library(tidyverse)
library(futile.logger)

source(here::here("transformer/utils/read_utils.R"))


#' @title Gera alertas para empresas inidoneas
#' @description Gera alertas para empresas inidoneas que estão presentes na lista de fornecedores
#' @return Dataframe com os alertas gerados
processa_alerta_inidoneas <- function() {
  flog.info("Processando alertas de itens atípicos por atividade econômica...")
  
  ceis <- read_csv(here::here("data/inidoneos/ceis.csv"), col_types = cols(.default = col_character())) %>% 
    mutate(fonte = "CEIS")
  
  cnep <- read_csv(here::here("data/inidoneos/cnep.csv"), 
                   col_types = cols(.default = col_character(),
                                    `VALOR DA MULTA` = col_double())) %>% 
    mutate(fonte = "CNEP")
  
  cadastros <- ceis %>% 
    bind_rows(cnep)
  
  fornecedores <- read_fornecedores_processados()
  
  fornecedores_inidoneos <- fornecedores %>% 
    inner_join(cadastros %>% 
                select(cnpj = `CPF OU CNPJ DO SANCIONADO`,
                       data_inicio = `DATA INÍCIO SANÇÃO`,
                       data_fim = `DATA FINAL SANÇÃO`,
                       num_processo = `NÚMERO DO PROCESSO`,
                       fonte),
               by = c("nr_documento" = "cnpj")) %>% 
    group_by(nr_documento) %>% 
    mutate(n_sancoes = n_distinct(num_processo)) %>% 
    ungroup() %>% 
    mutate(id_tipo = 3,
           id_contrato = NA_character_,
           info = str_glue("Este fornecedor foi encontrado no cadastro do {fonte} (nº de sanções: {n_sancoes}). ", 
                           "A última sanção tem o período de vigência entre {data_inicio} e {data_fim}.")) %>% 
    arrange(nr_documento, desc(data_inicio)) %>% 
    distinct(nr_documento, .keep_all = TRUE) %>% 
    select(nr_documento, id_contrato, id_tipo, info)
  
  flog.info(str_glue("{fornecedores_inidoneos %>% nrow()} alertas de fornecedores inidôneos foram capturados"))
  
  return(fornecedores_inidoneos)
}