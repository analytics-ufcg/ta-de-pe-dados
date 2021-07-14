library(tidyverse)
library(futile.logger)

source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/processor/geral/alertas/processa_alertas_data.R"))

#' @title Gera alertas para empresas inidoneas
#' @description Gera alertas para empresas inidoneas que estão presentes na lista de fornecedores
#' @param Anos para consideração dos contratos feitos com fornecedores sancionados. 
#' Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @return Dataframe com os alertas gerados
processa_alerta_inidoneas <- function(anos) {
  flog.info("Processando alertas de empresas inidôneas...")
  
  ceis <- read_csv(here::here("data/inidoneos/ceis.csv"), col_types = cols(.default = col_character())) %>% 
    mutate(fonte = "CEIS")
  
  cnep <- read_csv(here::here("data/inidoneos/cnep.csv"), 
                   col_types = cols(.default = col_character(),
                                    `VALOR DA MULTA` = col_double())) %>% 
    mutate(fonte = "CNEP")
  
  cadastros <- ceis %>% 
    bind_rows(cnep)
  
  fornecedores <- read_fornecedores_processados()
  
  contratos_merge <- processa_contratos_info(anos) %>% 
    distinct(id_contrato, nr_contrato, nr_documento_contratado, dt_inicio_vigencia)
  
  fornecedores_inidoneos <- fornecedores %>% 
    inner_join(cadastros %>% 
                select(cnpj = `CPF OU CNPJ DO SANCIONADO`,
                       data_inicio = `DATA INÍCIO SANÇÃO`,
                       data_fim = `DATA FINAL SANÇÃO`,
                       num_processo = `NÚMERO DO PROCESSO`,
                       fonte) %>% 
                 mutate(data_inicio = as.POSIXct(data_inicio, format="%d/%m/%Y"),
                        data_fim = as.POSIXct(data_fim, format="%d/%m/%Y")),
               by = c("nr_documento" = "cnpj")) %>% 
    inner_join(contratos_merge, 
               by = c("nr_documento" = "nr_documento_contratado")) %>% 
    group_by(nr_documento) %>% 
    mutate(n_sancoes = n_distinct(num_processo)) %>% 
    ungroup() %>% 
    filter((data_inicio <= dt_inicio_vigencia) & (dt_inicio_vigencia <= data_fim)) %>% 
    mutate(id_tipo = 3,
           info = str_glue("O fornecedor estava presente no {fonte} com uma sanção vigente durante o início do contrato. ", 
                           "A sanção tem o período de vigência de {format(data_inicio, '%d/%m/%Y')} a {format(data_fim, '%d/%m/%Y')}.")) %>% 
    arrange(nr_documento, desc(data_inicio)) %>% 
    distinct(nr_documento, id_contrato, .keep_all = TRUE) %>% 
    select(nr_documento, id_contrato, id_tipo, info)
  
  flog.info(str_glue("{fornecedores_inidoneos %>% nrow()} alertas de fornecedores inidôneos foram capturados"))
  
  return(fornecedores_inidoneos)
}