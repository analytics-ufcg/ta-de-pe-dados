source(here::here('code/utils/utils.R'))

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