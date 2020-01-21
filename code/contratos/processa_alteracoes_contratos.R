library(tidyverse)
library(here)
library(janitor)

#' Processa dados de alteração de contratos do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura das alterações dos contratos
#' 
#' @return Dataframe com informações das alterações dos contratos
#' 
#' @examples 
#' alteracoes_contratos <- import_alteracoes_contratos(c(2017, 2018, 2019))
#' 
import_alteracoes_contratos <- function(anos = c(2017, 2018, 2019)) {
  
  alteracoes_contratos <- pmap_dfr(list(anos),
                        ~ import_alteracoes_contratos_por_ano(..1)
  )
  
  return(alteracoes_contratos)
}

#' Importa dados de contratos em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação das alterações dos contratos
#'
#' @return Dataframe com informações das alterações dos contratos
#'   
#' @examples 
#' alteracoes_contratos <- import_alteracoes_contratos_por_ano(2019)
#' 
import_alteracoes_contratos_por_ano <- function(ano = 2017) {
  message(paste0("Importando alterações dos contratos do ano ", ano))

  ## Limpando dados 
  file_path <- here(paste0("data/contratos/", ano, "/alteracao.csv"))
  writeLines(iconv(readLines(file_path, skipNul = TRUE)), file_path)
  
  ## Lendo dados tratados
  alteracoes_contratos <- read_csv(file_path, 
                                   col_types = cols(.default = "c",
                                                    ANO_LICITACAO = "i"))
  
  return(alteracoes_contratos)
}

#' Processa dados para a tabela de alterações dos contratos de merenda no Rio Grande do Sul
#' 
#' @param anos Vector de inteiros com anos para captura das alterações dos contratos
#'
#' @return Dataframe com informações das alterações dos contratos de merenda
#'   
#' @examples 
#' info_alteracoes_contratos <- processa_info_alteracoes_contratos(c(2017, 2018, 2019))
#' 
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, 
#' tp_instrumento_contrato, id_evento_contrato, cd_tipo_operacao)
processa_info_alteracoes_contratos <- function(anos = c(2017, 2018, 2019)) {
  source(here("code/contratos/processa_contratos.R"))
  source(here("code/contratos/processa_tipos_alteracao_contrato.R"))
  
  contratos_merenda <- processa_info_contratos(anos) %>% 
    select(id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato)
  
  alteracoes_contratos <- import_alteracoes_contratos(anos)
  
  tipo_operacao_alteracao <- processa_tipos_alteracao_contrato()
  
  info_alteracoes_contrato <- alteracoes_contratos %>%
    inner_join(contratos_merenda, 
               by = c("CD_ORGAO" = "id_orgao", "NR_LICITACAO" = "nr_licitacao", 
                      "CD_TIPO_MODALIDADE" = "cd_tipo_modalidade",
                      "ANO_LICITACAO" = "ano_licitacao", "NR_CONTRATO" = "nr_contrato",
                      "ANO_CONTRATO" = "ano_contrato", "TP_INSTRUMENTO" = "tp_instrumento_contrato")) %>% 
    clean_names() %>%
    select(cd_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, 
           tp_instrumento_contrato = tp_instrumento, sq_evento, cd_tipo_operacao, 
           nr_dias_novo_prazo, vl_acrescimo, vl_reducao, pc_acrescimo, 
           pc_reducao, ds_justificativa) %>%
    left_join(tipo_operacao_alteracao, by = c("cd_tipo_operacao")) %>%
    rename(id_orgao = cd_orgao,
           id_evento_contrato = sq_evento,
           vigencia_novo_contrato = nr_dias_novo_prazo,
           motivo_alteracao_contrato = tipo_operacao_alteracao)
  
  return(info_alteracoes_contrato)
}

