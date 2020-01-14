
rename_duplicate_columns <- function(itens) {
  names(itens)[names(itens) == 'TP_DOCUMENTO'] <- 'TP_DOCUMENTO_VENCEDOR'
  names(itens)[names(itens) == 'NR_DOCUMENTO'] <- 'NR_DOCUMENTO_VENCEDOR'
  names(itens)[names(itens) == 'TP_DOCUMENTO_1'] <- 'TP_DOCUMENTO_FORNECEDOR'
  names(itens)[names(itens) == 'NR_DOCUMENTO_1'] <- 'NR_DOCUMENTO_FORNECEDOR'
  itens
}

generate_id <- function(itens, ano) {
  itens$ID <- paste0(ano, seq.int(nrow(itens)))
  itens
}

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