#' Lê arquivo csv de licitações
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de licitações
read_licitacoes <- function(source) {
  licitacoes <- readr::read_csv(here::here(paste0("data/licitacoes/", source,"/licitacao.csv")),
                                col_types = list(
                                  .default = readr::col_character(),
                                  NR_LICITACAO = readr::col_character(),
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
  return(licitacoes)
}


#' Lê arquivo csv de itens de licitações
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de itens de licitações
read_itens <- function(source) {
  itens <- readr::read_csv(here::here(paste0("data/licitacoes/", source,"/item.csv")),
                           col_types = list(
                             .default = readr::col_character(),
                             NR_LICITACAO = readr::col_character(),
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

#' Lê arquivo csv de contratos
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de contratos
read_contratos <- function(source) {
  contratos <- readr::read_csv(here::here(paste0("data/contratos/", source, "/contrato.csv")),
                               col_types = list(
                                 .default = readr::col_character(),
                                 ANO_LICITACAO = readr::col_integer(),
                                 NR_LICITACAO = readr::col_character(),
                                 NR_CONTRATO = readr::col_character(),
                                 ANO_CONTRATO = readr::col_integer(),
                                 ANO_PROCESSO = readr::col_integer(),
                                 DT_INICIO_VIGENCIA = readr::col_datetime(format = ""),
                                 DT_FINAL_VIGENCIA = readr::col_datetime(format = ""),
                                 VL_CONTRATO = readr::col_double(),
                                 DT_ASSINATURA = readr::col_datetime(format = ""),
                                 NR_DIAS_PRAZO = readr::col_integer()

                               ))
  return(contratos)

}

#' Lê arquivo csv de itens de contratos
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de itens de contratos
read_itens_contrato <- function(source) {
  itens <- readr::read_csv(here::here(paste0("data/contratos/", source, "/item_con.csv")),
                           col_types = list(
                             .default = readr::col_character(),
                             ANO_LICITACAO = readr::col_integer(),
                             NR_LICITACAO = readr::col_character(),
                             NR_CONTRATO = readr::col_character(),
                             ANO_CONTRATO = readr::col_integer(),
                             NR_LOTE = readr::col_integer(),
                             NR_ITEM = readr::col_integer(),
                             QT_ITENS = readr::col_number(),
                             VL_ITEM = readr::col_double(),
                             VL_TOTAL_ITEM = readr::col_double(),
                             PC_BDI = readr::col_double(),
                             PC_ENCARGOS_SOCIAIS = readr::col_double()
                           ))
  return(itens)
}

#' Lê arquivo csv de licitantes
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de licitantes
read_licitantes <- function(source) {
  licitantes <- readr::read_csv(here::here(paste0("data/licitacoes/", source, "/licitante.csv")),
                                col_types = cols(.default = readr::col_character(),
                                                 NR_LICITACAO = readr::col_character(),
                                                 ANO_LICITACAO = readr::col_integer()))
  return(licitantes)

}

#' Lê arquivo csv de alterações de contratos
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de alterações de contratos
read_alteracoes_contratos <- function(source) {
  file_path <- here::here(paste0("data/contratos/", source, "/alteracao.csv"))

  alteracoes_contratos <- readr::read_csv(file = readLines(file_path, skipNul = TRUE),
                                          col_types = cols(.default = readr::col_character(),
                                                           ANO_LICITACAO = readr::col_integer(),
                                                           NR_LICITACAO = readr::col_character(),
                                                           NR_CONTRATO = readr::col_character(),
                                                           ANO_CONTRATO = readr::col_integer()
                                          ))
  return(alteracoes_contratos)

}

#' Lê arquivo csv de fornecedores de contratos
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de fornecedores de contratos
read_fornecedores_contratos <- function(source) {
  forencedores <- readr::read_csv(here::here(paste0("data/contratos/", source, "/pessoas.csv")),
                                  col_types = list(
                                    .default = readr::col_character())
                                  )
  return(forencedores)

}

#' Lê arquivo csv de documentos das licitações
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de documentos das licitações
read_documentos_licitacoes <- function(source) {
  documentos <- readr::read_csv(here::here(paste0("data/licitacoes/", source, "/documento_lic.csv")),
                                  col_types = list(.default = readr::col_character(),
                                                   NR_LICITACAO = readr::col_character(),
                                                   ANO_LICITACAO = readr::col_integer())
  )
  return(documentos)

}

#' Lê arquivo csv de eventos das licitações
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de eventos das licitações
read_eventos_licitacoes <- function(source) {
  eventos <- readr::read_csv(here::here(paste0("data/licitacoes/", source, "/evento_lic.csv")),
                                col_types = list(.default = readr::col_character(),
                                                 ANO_LICITACAO = readr::col_integer())
  )
  return(eventos)

}

#' Lê arquivo csv de lotes das licitações
#' @param source Ano correspondente ao arquivo para leitura
#' @return Dataframe de lotes das licitações
read_lotes_licitacoes <- function(source) {
  lotes <- readr::read_csv(here::here(paste0("data/licitacoes/", source, "/lote.csv")),
                             col_types = list(.default = readr::col_character(),
                                              NR_LOTE = readr::col_integer(),
                                              ANO_LICITACAO = readr::col_integer(),
                                              PC_TX_ESTIMADA = readr::col_number(),
                                              PC_TX_HOMOLOGADA = readr::col_number())
  )
  return(lotes)

}

read_orgaos <- function() {
  orgaos <- readr::read_csv(here::here("data/orgaos/orgaos.csv"),
                            col_types = list(
                              .default = readr::col_character(),
                              CD_ORGAO = readr::col_integer(),
                              CD_MUNICIPIO_TCERS = readr::col_integer(),
                              CD_MUNICIPIO_IBGE = readr::col_integer()
                            ))

  return(orgaos)
}

read_licitacoes_processadas <- function() {
  licitacoes_processadas <- readr::read_csv(here::here("./data/bd/info_licitacao.csv"),
                                col_types = list(
                                  .default = readr::col_character(),
                                  id_estado = readr::col_number(),
                                  id_orgao = readr::col_character(),
                                  nr_licitacao = readr::col_character(),
                                  ano_licitacao = readr::col_number(),
                                  vl_estimado_licitacao = readr::col_number(),
                                  data_abertura = readr::col_datetime(format = ""),
                                  data_homologacao = readr::col_datetime(format = ""),
                                  data_adjudicacao = readr::col_datetime(format = ""),
                                  vl_homologado = readr::col_number()
                                ))
  return(licitacoes_processadas)

}

read_orgaos_processados <- function() {
  orgao_municipio <- readr::read_csv(here::here("./data/bd/info_orgaos.csv"))
  return(orgao_municipio)
}

read_empenhos_processados <- function() {
  empenhos <-
    readr::read_csv(
      here::here("./data/bd/info_empenhos.csv"),
      col_types = list(
        id_empenho = readr::col_character(),
        cnpj_cpf = readr::col_character(),
        nr_empenho = readr::col_character(),
        vl_empenho = readr::col_number(),
        dt_operacao = readr::col_datetime(format = "")
      )
    )
  return(empenhos)
}

read_contratos_processados <- function() {
  contratos <- readr::read_csv(here::here("./data/bd/info_contrato.csv"),
                               col_types = list(
                                 .default = readr::col_character(),
                                 id_orgao = readr::col_character(),
                                 nr_contrato = readr::col_character(),
                                 ano_contrato = readr::col_integer(),
                                 nr_licitacao = readr::col_character(),
                                 ano_licitacao = readr::col_integer(),
                                 ano_processo = readr::col_integer(),
                                 dt_inicio_vigencia = readr::col_datetime(),
                                 dt_final_vigencia = readr::col_datetime(),
                                 vl_contrato = readr::col_double(),
                                 vigencia_original_do_contrato = readr::col_integer()
                               ))
}

read_fornecedores_processados <- function() {
  fornecedores <- readr::read_csv(here::here("data/bd/info_fornecedores_contrato.csv"),
                                  col_types = list(
                                    nr_documento = readr::col_character()
                                  ))
}

read_dados_cadastrais_processados <- function() {
  dados_cadastrais <- readr::read_csv(here::here("data/bd/dados_cadastrais.csv"),
                                      col_types = list(
                                        cnpj = col_character(),
                                        data_situacao_especial = col_character(),
                                        situacao_especial = col_character()
                                        ))
}

#------------------------------------ TCE-PE A PARTIR DAQUI ---------------------------------------------------#

#' Lê arquivo csv de licitações do estado de Pernambuco

#' @return Dataframe de licitações
read_licitacoes_pe <- function() {
  licitacoes <- readr::read_csv(here::here("data/tce_pe/licitacoes.csv"),
                                col_types = list(
                                  codigoPL = readr::col_character(),
                                  codigoUG = readr::col_character(),
                                  CodigoModalidade = readr::col_character(),
                                  DataPublicacaoJulgamento = readr::col_datetime(format = ""),
                                  CodigoNatureza = readr::col_character(),
                                  CodigoDescricaoObjeto = readr::col_character(),
                                  CodigoSituacaoLicitacao = readr::col_character(),
                                  CodigoEstagioLicitacao = readr::col_character(),
                                  CodigoObjeto = readr::col_character()
                                ))
  return(licitacoes)
}


read_orgaos_estaduais_pe <- function() {
  orgaos_estaduais <- readr::read_csv(here::here("data/tce_pe/ugs_estaduais.csv"),
                                      col_types = list(
                                        CODIGO_TCE = col_character()
                                      ))
}

read_orgaos_municipais_pe <- function() {
  orgaos_municipais <- readr::read_csv(here::here("data/tce_pe/ugs_municipais.csv"),
                                       col_types = list(
                                         ID_UNIDADE_GESTORA = col_character(),
                                         NATUREZA_ORGAO  = col_character()
                                       ))
}

read_municipios_pe <- function() {
  municipios <- readr::read_csv(here::here("data/tce_pe/municipios.csv"),
                                col_types = list(
                                  CodigoSagres = col_character(),
                                  CodigoIBGE  = col_character()
                                ))
}

#' Lê arquivo csv de contratos do estado de Pernambuco

#' @return Dataframe de contratos
read_contratos_pe <- function() {
  contratos <- readr::read_csv(here::here("data/tce_pe/contratos.csv"),
                               col_types = list(
                                 .default = readr::col_character(),
                                 CodigoContrato = readr::col_character(),
                                 NumeroContrato = readr::col_character(),
                                 AnoContrato = readr::col_integer(),
                                 NumeroProcesso = readr::col_character(),
                                 AnoProcesso = readr::col_integer(),
                                 CPF_CNPJ = readr::col_character(),
                                 NumeroDocumento = readr::col_character(),
                                 NumeroDocumentoAjustado = readr::col_character(),
                                 Vigencia = readr::col_character(),
                                 ValorContrato = readr::col_double()
                               ))
  return(contratos)

}

#' Lê arquivo csv de fornecedores de contratos de Pernambuco

#' @return Dataframe de fornecedores de contratos
read_fornecedores_contratos_pe <- function() {
  fornecedores <- readr::read_csv(here::here("data/tce_pe/fornecedores.csv"),
                                  col_types = list(
                                    .default = readr::col_character())
  )
  return(fornecedores)

}

read_itens_contrato_processados_pe <- function() {
  cnaes <- readr::read_csv(here::here("data/tce_pe/itens.csv"),
                           col_types = list(
                             .default = readr::col_character()
                           ))
}
  
read_cnaes_processados <- function() {
  cnaes <- readr::read_csv(here::here("data/bd/info_cnaes.csv"),
                                      col_types = list(
                                        .default = readr::col_character()
                                      ))
}

read_cnaes_secundarios_processados <- function() {
  cnaes <- readr::read_csv(here::here("data/bd/cnaes_secundarios.csv"),
                           col_types = list(
                             .default = readr::col_character()
                           ))
}

read_itens_contrato_processados <- function() {
  cnaes <- readr::read_csv(here::here("data/bd/info_item_contrato.csv"),
                           col_types = list(
                             .default = readr::col_character()
                           ))
}

read_itens_similares_processados <- function() {
  itens <- readr::read_csv(here::here("data/bd/itens_similares.csv"),
                           col_types = list(
                             .default = readr::col_character()
                           ))
}
