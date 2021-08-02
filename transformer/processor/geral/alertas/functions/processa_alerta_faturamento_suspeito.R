library(tidyverse)
library(futile.logger)

source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/processor/geral/alertas/functions/helpers/processa_contratos_info.R"))

#' @title Gera alertas para empresas com faturamento suspeito
#' @description Gera alertas para empresas com faturamento suspeito considerando o porte da empresa
#' cadastrado na Receita Federal
#' @param Anos para consideração dos contratos.
#' Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020, 2021)
#' @return Dataframe com os alertas gerados
processa_alerta_faturamento_suspeito <- function(anos) {
  flog.info("Processando alertas do faturamento de fornecedores de acordo com o porte...")
  
  dados_cadastrais <- read_dados_cadastrais_processados() %>% 
    mutate(
      limite_faturamento = case_when(
        porte_empresa == 'Microempresa' &
          opcao_pelo_mei == 'N' ~ 360000,
        porte_empresa == 'Microempresa' &
          opcao_pelo_mei == 'S' ~ 81000,
        porte_empresa == 'Empresa de pequeno porte' ~ 4800000
      ))
  
  fornecedores <- read_fornecedores_processados()
  contratos <- read_contratos_processados()
  
  fornecedores_faturamento <- fornecedores %>% 
    select(nr_documento, nm_pessoa) %>% 
    left_join(contratos %>% 
                select(id_contrato, nr_documento_contratado, ano_contrato, vl_contrato),
              by = c("nr_documento" = "nr_documento_contratado")) %>% 
    group_by(nr_documento, ano_contrato) %>% 
    summarise(nm_pessoa = first(nm_pessoa),
              contratado_anual = sum(vl_contrato)) %>% 
    ungroup()

  acima_limite_faturamento <- dados_cadastrais %>% 
    select(cnpj, limite_faturamento) %>% 
    left_join(fornecedores_faturamento, by = c("cnpj" = "nr_documento")) %>% 
    filter(contratado_anual > limite_faturamento) %>% 
    mutate(id_tipo = 4,
           id_contrato = as.character(ano_contrato), # para evitar que ids de alertas sejam duplicados
           info = str_glue("Fornecedor com total contratado ({format_real(contratado_anual)}) em {ano_contrato} ", 
                           "acima do faturamento permitido ({format_real(limite_faturamento)}) pelo seu porte na Receita Federal.")) %>% 
    select(nr_documento = cnpj, id_contrato, id_tipo, info)

  flog.info(str_glue("{acima_limite_faturamento %>% nrow()} alertas de fornecedores com",
                     "faturamento acima do permitido foram capturados"))

  return(acima_limite_faturamento)  
}

#' @title Formata string para Reais
#' @param values Valores para serem formatados
#' @param nsmall Número de casas após a vírgula
#' @return Números formatados
format_real <- function(values, nsmall = 0) {
  values %>%
    as.numeric() %>%
    format(nsmall = nsmall, decimal.mark = ",", big.mark = ".") %>%
    str_trim() %>%
    str_c("R$ ", .)
}
