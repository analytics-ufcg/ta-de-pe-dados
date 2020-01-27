#' Lê arquivo csv de licitações
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de licitações
read_licitacoes <- function(source) {
  licitacoes <- readr::read_csv(here::here(paste0("data/licitacoes/", source,"/licitacao.csv")), 
                                col_types = list(
                                  .default = readr::col_character(),
                                  NR_LICITACAO = readr::col_integer(),
                                  ANO_LICITACAO = readr::col_integer(),
                                  ANO_PROCESSO = readr::col_integer(),
                                  DT_AUTORIZACAO_ADESAO = readr::col_datetime(format = ""),
                                  ANO_LICITACAO_ORIGINAL = readr::col_integer(),
                                  DT_ATA_REGISTRO_PRECO = readr::col_datetime(format = ""),
                                  PC_TAXA_RISCO = readr::col_double(),
                                  DT_INICIO_INSCR_CRED = readr::col_datetime(format = ""),
                                  DT_FIM_INSCR_CRED = readr::col_datetime(format = ""),
                                  DT_INICIO_VIGEN_CRED = readr::col_datetime(format = ""),
                                  DT_FIM_VIGEN_CRED = readr::col_datetime(format = ""),
                                  VL_LICITACAO = readr::col_double(),
                                  DT_ABERTURA = readr::col_datetime(format = ""),
                                  DT_HOMOLOGACAO = readr::col_datetime(format = ""),
                                  DT_ADJUDICACAO = readr::col_datetime(format = ""),
                                  VL_HOMOLOGADO = readr::col_double(),
                                  PC_TX_ESTIMADA = readr::col_double(),
                                  PC_TX_HOMOLOGADA = readr::col_double()
                                ))
}

#' Lê arquivo csv de itens de licitações
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de itens de licitações
read_itens <- function(source) {
  itens <- readr::read_csv(here::here(paste0("data/licitacoes/", source,"/item.csv")), 
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
}

#' Lê arquivo csv de licitantes
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de licitantes
read_licitantes <- function(source) {
  licitantes <- readr::read_csv(here::here(paste0("data/licitacoes/", source, "/licitante.csv")), 
                                col_types = cols(.default = readr::col_character(),
                                                 NR_LICITACAO = readr::col_integer(),
                                                 ANO_LICITACAO = readr::col_integer()))
}