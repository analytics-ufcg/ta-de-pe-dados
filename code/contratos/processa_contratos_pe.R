source(here::here("code/utils/read_utils.R"))

#' Importa dados de contratos para o estado de Pernambuco
#'
#' @return Dataframe com informações dos contratos
#'
#' @examples
#' contratos <- import_contratos()
#'
import_contratos_pe <- function() {
  message(paste0("Importando contratos de Pernambuco"))
  contratos <- read_contratos_pe()

  return(contratos)
}

#' Processa dados para tabela de informações dos contratos de licitações no PE
#'
#' @param contratos_df Dataframe de contratos para padronização
#'
#' @return Dataframe com informações dos contratos
#'
#' @examples
#' contratos <- import_info_contratos(contratos_df)
#'
#' Chave primária:
#' (a ser definida)
processa_info_contratos_pe <- function(contratos_df) {

  info_contratos <- contratos_df %>%
    janitor::clean_names() %>%
    select(nr_contrato = numero_contrato, ano_contrato, id_orgao = codigo_ug, nm_orgao = unidade_gestora,
           nr_processo = numero_processo, ano_processo, tp_documento_contratado = tipo_documento,
           nr_documento_contratado = numero_documento, vigencia, vl_contrato = valor_contrato,
           descricao_objeto_contrato = objeto)
}
