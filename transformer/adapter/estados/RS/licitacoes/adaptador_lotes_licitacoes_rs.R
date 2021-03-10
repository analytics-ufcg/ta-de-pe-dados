library(here)
library(janitor)
source(here::here('code/utils/read_utils.R'))
source(here::here('code/utils/utils.R'))

#' Importa lotes das licitações de um ano específico
#' @param ano Inteiro com o ano para recuperação dos lotes
#' @return Dataframe com informações dos lotes das licitações
#' @examples 
#' lotes <- import_lotes_licitacao_por_ano(2019)
import_lotes_licitacao_por_ano <- function(ano) {
  message(paste0("Importando lotes das licitações do ano ", ano))
  
  lotes <- read_lotes_licitacoes(ano)
  
  return(lotes)
}

#' Processa dados de lotes das licitações para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos lotes das licitações
#' 
#' @return Dataframe com informações dos lotes das licitações
#' 
#' @examples 
#' lotes_licitacao <- import_lotes_licitacao(c(2017, 2018, 2019))
#' 
import_lotes_licitacao <- function(anos = c(2017, 2018, 2019)) {
  
  lotes_licitacao <- purrr::pmap_dfr(list(anos),
                                     ~ import_lotes_licitacao_por_ano(..1)
  )
  
  return(lotes_licitacao)
}

#' Processa dados com informações dos vencedores dos lotes
#' 
#' @param lotes_licitacao Dataframe com informações dos lotes
#'
#' @return Dataframe com informações dos vencedores dos lotes das licitações
#'   
#' @examples 
#' info_lote_licitacao <- processa_info_lote_licitacao(import_lotes_licitacao(c(2017, 2018, 2019)))
#' 
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_lote)
#' 
processa_info_lote_licitacao <- function(lotes_licitacao) {
  
  info_lote_licitacao <- lotes_licitacao %>%
    rename_duplicate_columns() %>% 
    janitor::clean_names() %>%
    dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_lote, ds_lote,
                  vl_estimado, vl_homologado, tp_resultado_lote, 
                  tp_documento_vencedor, nr_documento_vencedor,
                  tp_documento_fornecedor, nr_documento_fornecedor, 
                  tp_beneficio_micro_epp, pc_tx_estimada, pc_tx_estimada)
  
  return(info_lote_licitacao)
}
