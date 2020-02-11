#' Gera um identificador único para cada registro do dataframe
#' @param df Dataframe sem identificador único
#' @param constante Identificador da tabela
#' @param id Nome da coluna do identificador
#' @return Dataframe com identificador único
generate_id <- function(df, constante, id) {
  df[, id] <- paste0(constante, df$ano_licitacao, seq.int(nrow(df)))
  df
}

read_licitacoes <- function(source) {
  licitacoes <- readr::read_csv(here::here(paste0("data/licitacoes/", source,"/licitacao.csv")), 
                                            col_types = list(
                                              .default = readr::col_character(),
                                              NR_LICITACAO = readr::col_number(),
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

read_itens <- function(source) {
  itens <- readr::read_csv(here::here(paste0("data/licitacoes/", source,"/item.csv")), 
                           col_types = list(
                             .default = readr::col_character(),
                             NR_LICITACAO = readr::col_number(),
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

read_itens_contrato <- function(source) {
  itens <- readr::read_csv(here::here(paste0("data/contratos/", source, "/item_con.csv")),
                           col_types = list(
                             .default = readr::col_character(),
                             ANO_LICITACAO = readr::col_integer(),
                             NR_LICITACAO = readr::col_number(),
                             NR_CONTRATO = readr::col_number(),
                             ANO_CONTRATO = readr::col_integer(),
                             NR_LOTE = readr::col_integer(),
                             NR_ITEM = readr::col_integer(),
                             QT_ITENS = readr::col_number(),
                             VL_ITEM = readr::col_double(),
                             VL_TOTAL_ITEM = readr::col_double(),
                             PC_BDI = readr::col_double(),
                             PC_ENCARGOS_SOCIAIS = readr::col_double()
                           ))
}
  
read_contratos <- function(source) {
  contratos <- readr::read_csv(here::here(paste0("data/contratos/", source, "/contrato.csv")),
                               col_types = list(
                                 .default = readr::col_character(),
                                 ANO_LICITACAO = readr::col_integer(),
                                 NR_LICITACAO = readr::col_number(),
                                 NR_CONTRATO = readr::col_number(),
                                 ANO_CONTRATO = readr::col_integer(),
                                 ANO_PROCESSO = readr::col_integer(),
                                 DT_INICIO_VIGENCIA = readr::col_datetime(format = ""),
                                 DT_FINAL_VIGENCIA = readr::col_datetime(format = ""),
                                 VL_CONTRATO = readr::col_double(),
                                 DT_ASSINATURA = readr::col_datetime(format = ""),
                                 NR_DIAS_PRAZO = readr::col_integer()
                                 
                               ))
  
}

read_orgaos <- function() {
  orgaos <- readr::read_csv(here::here("data/orgaos/orgaos.csv"),
                            col_types = list(
                              .default = readr::col_character(),
                              CD_ORGAO = readr::col_integer(),
                              CD_MUNICIPIO_TCERS = readr::col_integer(),
                              CD_MUNICIPIO_IBGE = readr::col_integer()
                            ))
}

read_alteracoes_contratos <- function(source) {
  file_path <- here::here(paste0("data/contratos/", source, "/alteracao.csv"))
  
  alteracoes_contratos <- readr::read_csv(file = readLines(file_path, skipNul = TRUE), 
                                          col_types = cols(.default = readr::col_character(),
                                                           ANO_LICITACAO = readr::col_integer(),
                                                           NR_LICITACAO = readr::col_number(),
                                                           NR_CONTRATO = readr::col_number(),
                                                           ANO_CONTRATO = readr::col_integer()
                                                           )
                                          )

}

read_licitantes <- function(source) {
  licitantes <- readr::read_csv(here::here(paste0("data/licitacoes/", source, "/licitante.csv")), 
                                col_types = cols(.default = readr::col_character(),
                                                 NR_LICITACAO = readr::col_number(),
                                                 ANO_LICITACAO = readr::col_integer()))

}

read_licitacoes_processadas <- function() {
  licitacoes <- readr::read_csv(here::here("./data/bd/info_licitacao.csv"), 
                                col_types = list(
                                  .default = readr::col_character(),
                                  id_licitacao = readr::col_number(),
                                  id_estado = readr::col_number(),
                                  id_orgao = readr::col_number(),
                                  nr_licitacao = readr::col_number(),
                                  ano_licitacao = readr::col_number(),
                                  vl_estimado_licitacao = readr::col_number(),
                                  data_abertura = readr::col_datetime(format = ""),
                                  data_homologacao = readr::col_datetime(format = ""),
                                  data_adjudicacao = readr::col_datetime(format = ""),
                                  vl_homologado = readr::col_number()
                                ))
}

read_orgaos_processados <- function() {
  orgao_municipio <- readr::read_csv(here::here("./data/bd/info_orgaos.csv"))
}
