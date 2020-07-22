library(here)
library(janitor)
source(here::here('code/utils/read_utils.R'))

#' Renomeia as colunas repetidas do dataframe de itens
#' @param itens Dataframe de itens das licitações
#' @return Dataframe com nome das colunas de acordo Manual do leiaute do e-Validador 
rename_duplicate_columns <- function(itens) {
  names(itens)[names(itens) == 'TP_DOCUMENTO'] <- 'TP_DOCUMENTO_VENCEDOR'
  names(itens)[names(itens) == 'NR_DOCUMENTO'] <- 'NR_DOCUMENTO_VENCEDOR'
  names(itens)[names(itens) == 'TP_DOCUMENTO_1'] <- 'TP_DOCUMENTO_FORNECEDOR'
  names(itens)[names(itens) == 'NR_DOCUMENTO_1'] <- 'NR_DOCUMENTO_FORNECEDOR'
  itens
}

#' Importa itens das licitações de um ano específico para o estado do Rio Grande do Sul
#' @param ano Inteiro com o ano para recuperação dos itens
#' @return Dataframe com informações dos itens das licitações
#' @examples 
#' itens <- import_itens_licitacao_por_ano(2019)
import_itens_licitacao_por_ano <- function(ano) {
  message(paste0("Importando itens das licitações do ano ", ano))
  
  itens <- read_itens(ano)
  
  return(itens)
}

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
  
  itens_licitacao <- purrr::pmap_dfr(list(anos),
                         ~ import_itens_licitacao_por_ano(..1)
  )
  
  return(itens_licitacao)
}

#' Processa dados para a tabela de informações dos itens das licitações
#' 
#' @param anos Vector de inteiros com anos para captura dos itens das licitações
#'
#' @return Dataframe com informações dos itens das licitações
#'   
#' @examples 
#' info_item_licitacao <- processa_info_item_licitacao(anos = c(2017, 2018, 2019))
#' 
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_lote, nr_item)
#' 
processa_info_item_licitacao <- function(itens_licitacao) {
  
  info_item_licitacao <- itens_licitacao %>% 
    rename_duplicate_columns() %>% 
    janitor::clean_names() %>%
    dplyr::select(id_orgao = cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_lote,  nr_item, 
           ds_item, qt_itens_licitacao = qt_itens, sg_unidade_medida, vl_unitario_estimado, 
           vl_total_estimado)
    
  return(info_item_licitacao)
}
