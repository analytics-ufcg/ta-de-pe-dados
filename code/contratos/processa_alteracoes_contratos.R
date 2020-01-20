library(tidyverse)
library(here)
library(janitor)

#' Importa dados de contratos em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação das alterações dos contratos
#'
#' @return Dataframe com informações das alterações dos contratos
#'   
#' @examples 
#' alteracoes_contratos <- import_alteracoes_contratos_por_ano(2019)
#' 
import_alteracoes_contratos_por_ano <- function(ano = 2017) {
  message(paste0("Importando alterações dos contratos do ano ", ano))

  ## Limpando dados 
  file_path <- here::here(paste0("data/contratos/", ano, "/alteracao.csv"))
  writeLines(iconv(readLines(file_path, skipNul = TRUE)), file_path)
  
  ## Lendo dados tratados
  alteracoes_contratos <- readr::read_csv(file_path, 
                                   col_types = cols(.default = "c",
                                                    ANO_LICITACAO = "i"))
  
  return(alteracoes_contratos)
}

#' Processa dados para a tabela de alterações dos contratos no Rio Grande do Sul
#' 
#' @param anos Vector de inteiros com anos para captura das alterações dos contratos
#'
#' @return Dataframe com informações das alterações dos contratos
#'   
#' @examples 
#' info_alteracoes_contratos <- processa_info_alteracoes_contratos(c(2017, 2018, 2019))
#' 
#' Chave primária: 
#' (cd_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, 
#' tp_instrumento_contrato, id_evento_contrato)
processa_info_alteracoes_contratos <- function(anos = c(2017, 2018, 2019, 2020)) {
  source(here::here("code/contratos/processa_tipos_alteracao_contrato.R"))
  source(here::here("code/utils/constants.R"))
  source(here::here("code/utils/utils.R"))
  
  alteracoes_contratos <- tibble::tibble(ano_arquivo = anos) %>% 
    dplyr::mutate(data = purrr::map(ano_arquivo,
                                    import_alteracoes_contratos_por_ano)) %>% 
    tidyr::unnest(data)
  
  tipo_operacao_alteracao <- processa_tipos_alteracao_contrato()
  
  info_alteracoes_contrato <- alteracoes_contratos %>%
    janitor::clean_names() %>%
    dplyr::left_join(tipo_operacao_alteracao, by = c("cd_tipo_operacao")) %>%
    dplyr::select(
      ano_arquivo,
      cd_orgao,
      ano_licitacao,
      nr_licitacao,
      cd_tipo_modalidade,
      nr_contrato,
      ano_contrato,
      tp_instrumento_contrato = tp_instrumento,
      id_evento_contrato = sq_evento,
      cd_tipo_operacao,
      vigencia_novo_contrato = nr_dias_novo_prazo,
      vl_acrescimo,
      vl_reducao,
      pc_acrescimo,
      pc_reducao,
      ds_justificativa,
      motivo_alteracao_contrato = tipo_operacao_alteracao
    ) %>% 
    dplyr::filter(!is.na(ano_licitacao)) %>% 
    generate_id("ano_arquivo", TABELA_ALTERACOES_CONTRATO, ALTERACOES_CONTRATO_ID) %>% 
    select(-ano_arquivo)
  
  return(info_alteracoes_contrato)
}
