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
#' (codigo_contrato)
adapta_info_contratos_pe <- function(contratos_df) {

  info_contratos <- contratos_df %>%
    janitor::clean_names() %>%
    mutate(tp_instrumento_contrato = NA_character_,
           contrato_possui_garantia = NA_character_,
           vigencia_original_do_contrato = NA_integer_,
           justificativa_contratacao = NA_character_,
           obs_contrato = NA_character_,
           tipo_instrumento_contrato = NA_character_) %>% 
    select(codigo_contrato = codigo_contrato_original, nr_contrato = numero_contrato, ano_contrato, 
           cd_orgao = codigo_uj, nm_orgao = nome_uj,
           nr_processo = numero_processo, ano_processo, tp_documento_contratado = tipo_documento_contratado,
           nr_documento_contratado = cpfcnpj_contratado, dt_inicio_vigencia = data_inicio_vigencia, 
           dt_final_vigencia = data_fim_vigencia, vl_contrato = valor_contrato, tp_instrumento_contrato, 
           contrato_possui_garantia, vigencia_original_do_contrato, justificativa_contratacao, obs_contrato,
           tipo_instrumento_contrato,
           descricao_objeto_contrato = especificacao_objeto, nr_licitacao = codigo_pl) %>% 
    dplyr::mutate(nr_documento_contratado = str_replace_all(nr_documento_contratado, "[[:punct:]]", "")) %>% 
    dplyr::mutate(tp_documento_contratado = 
                    dplyr::case_when(
                      tp_documento_contratado == "CPF" ~ "F",
                      tp_documento_contratado == "CNPJ" ~ "J",
                      TRUE ~ tp_documento_contratado
                    )) %>% 
    dplyr::distinct(codigo_contrato, .keep_all = TRUE)
}
