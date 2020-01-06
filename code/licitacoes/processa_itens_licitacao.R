library(tidyverse)
library(here)
library(janitor)

#' Processa dados de itens das licitações do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos itens das licitações
#' 
#' @return Dataframe com informações dos itens das licitações
#' 
#' @examples 
#' itens_licitacao <- import_itens_licitacao(c(2017, 2018, 2019))
#' 
import_itens_licitacao <- function(anos = c(2017, 2018, 2019)) {
  
  itens_licitacao <- pmap_dfr(list(anos),
                         ~ import_itens_licitacao_por_ano(..1)
  )
  
  return(itens_licitacao)
}

#' Importa dados de itens das licitações em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação dos itens das licitações
#'
#' @return Dataframe com informações dos itens das licitações
#'   
#' @examples 
#' itens_licitacao <- import_itens_licitacao_por_ano(2019)
#' 
import_itens_licitacao_por_ano <- function(ano = 2019) {
  message(paste0("Importando itens de licitação do ano ", ano))
  itens_licitacao <- read_csv(here(paste0("data/licitacoes/", ano, "/item.csv")), col_types = cols(.default = "c", 
                                                                                                   VL_LICITACAO = "d"))
  
  return(itens_licitacao)
}

#' Processa dados para a tabela de informações dos itens das licitações de merenda
#' 
#' @param anos Vector de inteiros com anos para captura dos itens das licitações
#'
#' @return Dataframe com informações dos itens das licitações de merenda
#'   
#' @examples 
#' info_item_licitacao <- processa_info_item_licitacao(anos = c(2017, 2018, 2019))
#' 
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_lote, nr_item)
#' 
processa_info_item_licitacao <- function(anos = c(2017, 2018, 2019)) {
  source(here("code/licitacoes/processa_licitacoes.R"))
  
  licitacoes_merenda <- import_licitacoes_merenda(anos) %>% 
    select(CD_ORGAO, NR_LICITACAO, ANO_LICITACAO, CD_TIPO_MODALIDADE)
  
  itens_licitacao <- import_itens_licitacao(anos)
  
  info_item_licitacao <- itens_licitacao %>% 
    right_join(licitacoes_merenda, by = c("CD_ORGAO", "NR_LICITACAO", "ANO_LICITACAO", "CD_TIPO_MODALIDADE")) %>% 
    mutate(id_estado = "43") %>%
    distinct() %>%
    clean_names() %>%
    select(id_estado, id_orgao = cd_orgao, ano_licitacao, cd_tipo_modalidade, nr_lote, nr_licitacao, nr_item, 
           ds_item, qt_itens_licitacao = qt_itens, sg_unidade_medida, vl_unitario_estimado, 
           vl_total_estimado)
    
  return(info_item_licitacao)
}
