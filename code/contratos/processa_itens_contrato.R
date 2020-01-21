library(tidyverse)
library(here)
library(janitor)

#' Processa dados de itens dos contratos do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos itens dos contratos
#' 
#' @return Dataframe com informações dos itens dos contratos
#' 
#' @examples 
#' itens_contrato <- import_itens_contrato(c(2017, 2018, 2019))
#' 
import_itens_contrato <- function(anos = c(2017, 2018, 2019)) {
  
  itens_contrato <- pmap_dfr(list(anos),
                              ~ import_itens_contrato_por_ano(..1)
  )
  
  return(itens_contrato)
}

#' Importa dados de itens dos contratos em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação dos itens dos contratos
#'
#' @return Dataframe com informações dos itens dos contratos
#'   
#' @examples 
#' itens_contrato <- import_itens_contrato_por_ano(2019)
#' 
import_itens_contrato_por_ano <- function(ano = 2019) {
  message(paste0("Importando itens de contrato do ano ", ano))
  itens_contrato <- read_csv(here(paste0("data/contratos/", ano, "/item_con.csv")), 
                              col_types = cols(.default = "c",
                                               ANO_LICITACAO = "i"))
  
  return(itens_contrato)
}

#' Processa dados para a tabela de informações dos itens dos contratos de merenda
#' 
#' @param anos Vector de inteiros com anos para captura dos itens dos contratos
#'
#' @return Dataframe com informações dos itens dos contratos de merenda
#'   
#' @examples 
#' info_item_contrato <- processa_info_item_contrato(anos = c(2017, 2018, 2019))
#'
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato,
#' nr_lote, nr_item)
processa_info_item_contrato <- function(anos = c(2017, 2018, 2019)) {
  source(here("code/contratos/processa_contratos.R"))
  
  contratos_merenda <- processa_info_contratos(anos) %>% 
    select(id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato)
  
  itens_contrato <- import_itens_contrato(anos)
  
  info_item_contrato <- itens_contrato %>% 
    right_join(contratos_merenda, 
               by = c("CD_ORGAO" = "id_orgao", "NR_LICITACAO" = "nr_licitacao", 
                      "CD_TIPO_MODALIDADE" = "cd_tipo_modalidade",
                      "ANO_LICITACAO" = "ano_licitacao", "NR_CONTRATO" = "nr_contrato",
                      "ANO_CONTRATO" = "ano_contrato", "TP_INSTRUMENTO" = "tp_instrumento_contrato")) %>% 
    distinct(CD_ORGAO, NR_LICITACAO, ANO_LICITACAO, CD_TIPO_MODALIDADE, NR_CONTRATO, 
             ANO_CONTRATO, TP_INSTRUMENTO, NR_LOTE, NR_ITEM, .keep_all=TRUE) %>%
    rename(QT_ITENS_CONTRATO = QT_ITENS,
           VL_ITEM_CONTRATO = VL_ITEM,
           VL_TOTAL_ITEM_CONTRATO = VL_TOTAL_ITEM) %>%
    select(-c(PC_BDI, PC_ENCARGOS_SOCIAIS)) %>%
    mutate_all(as.character) %>%
    clean_names() %>%
    mutate(id_estado = "43") %>% 
    select(id_estado, id_orgao = cd_orgao, nr_lote, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, 
           ano_contrato, tp_instrumento_contrato = tp_instrumento, nr_item, qt_itens_contrato, 
           vl_item_contrato, vl_total_item_contrato)
  
  return(info_item_contrato)
}
