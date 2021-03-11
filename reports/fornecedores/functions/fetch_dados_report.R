library(tidyverse)
library(here)

#' Recupera dataframe com informações dos fornecedores incluindo a data de início das atividades e data do primeiro contrato
#' @return Dataframe de fornecedores. Uma fornecedor pode ter mais de uma linha caso tenha realizado mais de um contrato no mesmo dia
#' (sendo esse dia o dia dos seus primeiros contratos).
#' @examples 
#' fornecedores <- fetch_diferenca_abertura_contrato()
#' 
fetch_diferenca_abertura_contrato <- function() {
  source(here::here("transformer/adapter/RS/contratos/adaptador_contratos_rs.R"))
  source(here::here("transformer/utils/read_utils.R"))
  
  fornecedores_tce <- read_csv(here("data/bd/info_fornecedores_contrato.csv"))
  
  fornecedores_receita <- read_csv(here("data/bd/dados_cadastrais.csv"),
                                   col_types = cols(data_situacao_especial = col_character(),
                                                     situacao_especial = col_character()))

  fornecedores <- fornecedores_tce %>% 
    left_join(fornecedores_receita %>% 
                select(cnpj, razao_social, nome_fantasia, codigo_natureza_juridica, data_inicio_atividade,
                       porte_empresa),
              by = c("nr_documento" = "cnpj")) %>% 
    mutate(diferenca_abertura_contrato = difftime(data_primeiro_contrato, data_inicio_atividade, units="days"))
  
  contratos_processados <- read_contratos_processados() %>% 
    mutate(id_orgao = as.character(id_orgao)) %>% 
    select(id_contrato, id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato,
           nm_orgao, nr_documento_contratado, dt_inicio_vigencia, vl_contrato, descricao_objeto_contrato)
  
  contratos <- import_contratos(c(2018, 2019, 2020)) %>% 
    processa_info_contratos() %>% 
    select(id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato,
           nm_orgao, nr_documento_contratado, dt_inicio_vigencia, vl_contrato, descricao_objeto_contrato)
  
  contratos_merge <- contratos_processados %>% 
    bind_rows(contratos) %>% 
    distinct(id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato, .keep_all = T)
  
  fornecedores_contratos <- fornecedores %>% 
    left_join(contratos_merge, by = c("nr_documento" = "nr_documento_contratado", "data_primeiro_contrato" = "dt_inicio_vigencia"))
  
  return(fornecedores_contratos)
}

#' @title Formata valor para exibição de montante (2500000 para 2.5 milhões)
#' @description Formata valor para exibição de montante (2500000 para 2.5 milhões)
#' @param tx Número para ser formatado
#' @return String com número formatado
#' @examples
#' format_currency(2500000)
format_currency <- function(tx) { 
  div <- findInterval(as.numeric(gsub("\\,", "", tx)), 
                      c(0, 1e3, 1e6, 1e9) )
  paste(round(as.numeric(gsub("\\,", "", tx))/10^(3*(div-1)), 2), 
        c("", "mil", "milhões", "bilhões")[div] )
}
