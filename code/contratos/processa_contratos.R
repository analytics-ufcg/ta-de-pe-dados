library(tidyverse)
library(here)
library(janitor)

#' Processa dados de contratos do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos contratos
#' 
#' @return Dataframe com informações dos contratos
#' 
#' @examples 
#' contratos <- import_contratos(c(2017, 2018, 2019))
#' 
import_contratos <- function(anos = c(2017, 2018, 2019)) {
  
  contratos <- pmap_dfr(list(anos),
                         ~ import_contratos_por_ano(..1)
  )
  
  return(contratos)
}

#' Importa dados de contratos em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação dos contratos
#'
#' @return Dataframe com informações dos contratos
#'   
#' @examples 
#' contratos <- import_contratos_por_ano(2019)
#' 
import_contratos_por_ano <- function(ano = 2019) {
  message(paste0("Importando contratos do ano ", ano))
  contratos <- read_csv(here(paste0("data/contratos/", ano, "/contrato.csv")), 
                        col_types = cols(.default = "c",
                                         ANO_LICITACAO = "i"))
  
  return(contratos)
}

#' Processa dados para tabela de informações dos contratos de licitações de merenda no RS
#' 
#' @param anos Vector de inteiros com anos para captura dos contratos
#'
#' @return Dataframe com informações dos contratos
#'   
#' @examples 
#' contratos <- import_contratos_por_ano(c(2017, 2018, 2019))
#' 
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato)
processa_info_contratos <- function(anos = c(2017, 2018, 2019)) {
  source(here("code/contratos/processa_tipos_instrumento_contrato.R"))
  source(here("code/licitacoes/processa_licitacoes.R"))
  
  licitacoes_merenda <- import_licitacoes_merenda(anos) %>% 
    select(CD_ORGAO, NR_LICITACAO, ANO_LICITACAO, CD_TIPO_MODALIDADE)
    
  tipo_instrumento_contrato <- processa_tipos_instrumento_contrato()
  
  todos_contratos <- import_contratos(anos)
  
  info_contratos <- todos_contratos %>%
    right_join(licitacoes_merenda, by = c("CD_ORGAO", "NR_LICITACAO", "ANO_LICITACAO", "CD_TIPO_MODALIDADE")) %>% 
    clean_names() %>%
    mutate(id_estado = "43") %>% ## Id do Rio Grande do Sul
    left_join(tipo_instrumento_contrato, by = c("tp_instrumento" = "tp_instrumento_contrato")) %>%
    select(id_estado, id_orgao = cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato,
           tp_instrumento_contrato = tp_instrumento, nr_processo, ano_processo, tp_documento_contratado = tp_documento,
           nr_documento_contratado = nr_documento, dt_inicio_vigencia, dt_final_vigencia, vl_contrato, 
           contrato_possui_garantia = bl_garantia, vigencia_original_do_contrato = nr_dias_prazo,
           descricao_objeto_contrato = ds_objeto, justificativa_contratacao = ds_justificativa, 
           obs_contrato = ds_observacao) 
}
