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


#' Gera um identificador único para cada registro do dataframe
#' @param itens Dataframe sem identificador único
#' @param ano Inteiro com o ano para uso na criação do identificador
#' @return Dataframe com identificador único
generate_id <- function(df, ano) {
  df$ID <- paste0(ano, seq.int(nrow(df)))
  df
}


#' Importa itens das licitações de um ano específico para o estado do Rio Grande do Sul
#' @param ano Inteiro com o ano para recuperação dos itens
#' @return Dataframe com informações dos itens das licitações
#' @examples 
#' itens <- import_itens_licitacao_por_ano(2019)
import_itens_licitacao_por_ano <- function(ano) {
  message(paste0("Importando itens das licitações do ano ", ano))
  
  itens <- readr::read_csv(here::here(paste0("data/licitacoes/", ano, "/item.csv")), 
                           col_types = list(
                             .default = readr::col_character(),
                             ANO_LICITACAO = readr::col_integer(),
                             NR_LOTE = readr::col_integer(),
                             NR_ITEM = readr::col_integer(),
                             QT_ITENS = readr::col_double(),
                             VL_UNITARIO_ESTIMADO = readr::col_double(),
                             VL_TOTAL_ESTIMADO = readr::col_double(),
                             DT_REF_VALOR_ESTIMADO = readr::col_datetime(format = ""),
                             PC_BDI_ESTIMADO = readr::col_double(),
                             PC_ENCARGOS_SOCIAIS_ESTIMADO = readr::col_double(),
                             VL_UNITARIO_HOMOLOGADO = readr::col_double(),
                             VL_TOTAL_HOMOLOGADO = readr::col_double(),
                             PC_BDI_HOMOLOGADO = readr::col_double(),
                             PC_ENCARGOS_SOCIAIS_HOMOLOGADO = readr::col_double(),
                             CD_TIPO_FAMILIA = readr::col_integer(),
                             CD_TIPO_SUBFAMILIA = readr::col_integer(),
                             PC_TX_ESTIMADA = readr::col_double(),
                             PC_TX_HOMOLOGADA = readr::col_double()
                             
                           ))
  
  return(itens)
}