library(tidyverse)
library(magrittr)
library(futile.logger)
source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/utils/constants.R"))
source(here::here("transformer/processor/geral/alertas/functions/helpers/processa_contratos_info.R"))
source(here::here("transformer/processor/aggregator/agrega_contratos.R"))


#' Processa alertas de fornecedores com relação a diferença entre a data de abertura e a data do primeiro contrato
#' 
#' @param anos Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @param estados Array com os estados para considerar nos contratos
#' @return Dataframe com alertas para a diferença de datas
#' 
#' @examples 
#' alertas <- processa_alertas_data_abertura_contrato(c(2018, 2019, 2020), c("RS", "PE", "BR"))
processa_alertas_data_abertura_contrato <- function(anos, estados = c("RS", "PE", "BR")) {
  flog.info(str_glue("Processando alertas da data de abertura!"))
  LIMITE_DIFERENCA_DIAS = 30
  flog.info(str_glue("Diferença de dias entre a abertura e o primeiro contrato: {LIMITE_DIFERENCA_DIAS}"))
  
  fornecedores_tce <- read_fornecedores_processados()
  
  fornecedores_receita <- read_dados_cadastrais_processados()
  
  fornecedores <- fornecedores_tce %>% 
    left_join(fornecedores_receita %>% 
                select(cnpj, razao_social, nome_fantasia, codigo_natureza_juridica, data_inicio_atividade,
                       porte_empresa),
              by = c("nr_documento" = "cnpj")) %>% 
    mutate(diferenca_abertura_contrato = as.numeric(difftime(data_primeiro_contrato, data_inicio_atividade, units="days"))) %>% 
    filter(diferenca_abertura_contrato <= LIMITE_DIFERENCA_DIAS)
  
  flog.info(str_glue("{fornecedores %>% nrow()} fornecedores com o alerta!"))
  
  contratos_merge <- processa_contratos_info(anos, estados)
  flog.info(str_glue("Pesquisa feita em {contratos_merge %>% nrow()} contratos de {contratos_merge %>% count(id_estado) %>% nrow()} estados."))
  
  fornecedores_contratos <- fornecedores %>% 
    left_join(contratos_merge, by = c("nr_documento" = "nr_documento_contratado", 
                                      "data_primeiro_contrato" = "dt_inicio_vigencia"))
  
  alertas_data <- fornecedores_contratos %>% 
    filter(!is.na(nr_contrato)) %>% 
    mutate(id_tipo = 1) %>% 
    mutate(info = paste0("Contrato ", nr_contrato, "/", ano_contrato, " em ", nm_orgao)) %>% 
    select(nr_documento, id_contrato, id_tipo, info) %>% 
    distinct(nr_documento, info, .keep_all = TRUE)
  
  flog.info(str_glue("{alertas_data %>% nrow()} alertas de data de abertura gerados!"))
  
  return(alertas_data)
}
