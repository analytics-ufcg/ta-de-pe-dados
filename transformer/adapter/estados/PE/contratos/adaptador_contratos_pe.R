source(here::here("transformer/utils/read_utils.R"))

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
    select(codigo_contrato, nr_contrato = numero_contrato, ano_contrato, cd_orgao = codigo_ug, nm_orgao = unidade_gestora,
           nr_processo = numero_processo, ano_processo, tp_documento_contratado = tipo_documento,
           nr_documento_contratado = numero_documento, vigencia, vl_contrato = valor_contrato,
           descricao_objeto_contrato = objeto, nr_licitacao = codigo_pl) %>% 
    dplyr::mutate(nr_documento_contratado = str_replace_all(nr_documento_contratado, "[[:punct:]]", "")) %>% 
    dplyr::mutate(tp_documento_contratado = 
                    dplyr::case_when(
                      tp_documento_contratado == "CPF" ~ "F",
                      tp_documento_contratado == "CNPJ" ~ "J",
                      TRUE ~ tp_documento_contratado
                    )) %>% 
    separate(vigencia, c("dt_inicio_vigencia", "dt_final_vigencia"), " a ") %>% 
    mutate(dt_inicio_vigencia = lubridate::dmy(dt_inicio_vigencia), 
           dt_final_vigencia = lubridate::dmy(dt_final_vigencia))
}
