library(tidyverse)
library(futile.logger)
source(here::here("transformer/utils/read/read_empenhos_federais.R"))
source(here::here("transformer/utils/read_utils.R"))

#' Importa dados de empenhos para o Governo Federal
#' Os empenhos são usados para gerar as compras do governo federal
#' usadas no Tá de pé.
#'
#' @return Dataframe com informações dos empenhos
#'
#' @examples
#' empenhos <- import_empenhos_federal()
#'
import_empenhos_federal <- function() {
  message(paste0("Importando empenhos de Governo Federal"))
  source(here::here("transformer/utils/bd_constants.R"))
  
  # POSTGRES_HOST = 'postgres'
  # POSTGRES_USER = 'postgres'
  # POSTGRES_DB = 'tanamesa'
  # POSTGRES_PORT = 5432
  # POSTGRES_PASSWORD = 'secret'

  empenhos <-
    read_empenhos_federais_covid(POSTGRES_HOST,
                                 POSTGRES_USER,
                                 POSTGRES_DB,
                                 POSTGRES_PORT,
                                 POSTGRES_PASSWORD)

  return(empenhos)
}

#' Importa dados da ligação entre empenhos e licitação para o Governo Federal
#'
#' @return Dataframe com informações da ligação entre empenhos e licitação
#'
#' @examples
#' empenhos_licitacao <- import_empenhos_licitacao_federal()
#'
import_empenhos_licitacao_federal <- function() {
  message(paste0("Importando empenhos relacionados a licitação no Governo Federal"))
  
  emp_lic <- read_empenhos_licitacoes_federal()
  return(emp_lic)
}

#' Processa dados para tabela de informações das compras Do governo federal
#' As compras do governo federal são extraídas dos empenhos (notas de empenho)
#'
#' @param empenho_df Dataframe de empenhos para adaptação. Pode ser gerado a partir da função import_empenhos_federal()
#' @param empenhos_licitacao_df Dataframe que liga empenhos à licitações. Pode ser gerado a partir da função import_empenhos_licitacao_federal()
#' @param filtro Tipo de filtro para aplicação nos dados. Apenas 'covid' está disponível.
#'
#' @return Dataframe com informações das compras do governo federal
#'
#' @examples
#' compras_BR <- adapta_info_compras_federal(empenho_df, empenhos_licitacao_df, filtro)
#'
#' O codigo_favorecido para pessoas físicas pode causar repetições em conjuntos maiores de dados.
#' Já que é composto apenas por parte do CPF.
adapta_info_compras_federal <- function(empenho_df, empenhos_licitacao_df, filtro) {
  
  if (filtro == 'covid') {
    flog.info("Aplicando filtro de covid para as compras do Governo Federal")
  } else if (filtro == 'merenda') {
    flog.info("Filtro de merenda não está pronto para o Gov Federal")
    return(tibble())
  } else {
    stop("Tipo de filtro não definido. É possível filtrar pelos tipos 'merenda' ou 'covid")
  }
  
  empenhos_licitacao_df <- empenhos_licitacao_df %>% 
    distinct(codigo_empenho, numero_licitacao, codigo_modalidade_compra, .keep_all = TRUE) %>% 
    mutate(codigo_modalidade_compra = as.character(codigo_modalidade_compra), 
           codigo_ug = as.character(codigo_ug)) %>% 
    select(codigo_contrato = codigo_empenho,
           nr_licitacao = numero_licitacao,
           cd_tipo_modalidade = codigo_modalidade_compra,
           cd_orgao_lic = codigo_ug)
  
  compras_df <- empenho_df %>% 
    mutate(tp_instrumento_contrato = "Compra",
           tipo_instrumento_contrato = "Compra",
           contrato_possui_garantia = NA_character_,
           vigencia_original_do_contrato = NA_character_,
           justificativa_contratacao = NA_character_,
           data = as.Date(data_emissao, format = "%d/%m/%Y"),
           ano_contrato = lubridate::year(data),
           codigo_favorecido = str_replace_all(codigo_favorecido, "[[.-]]", "")) %>%
    mutate(tp_documento_contratado = case_when(
      nchar(codigo_favorecido) == 11 ~ 'F',
      nchar(codigo_favorecido) == 14 ~ 'J',
      TRUE ~ 'O'
    )) %>%
    select(
      codigo_contrato = codigo,
      nr_contrato = codigo_resumido,
      ano_contrato,
      cd_orgao = codigo_unidade_gestora,
      nm_orgao = unidade_gestora,
      nr_processo = processo,
      ano_processo = ano_contrato,
      tp_documento_contratado,
      nr_documento_contratado = codigo_favorecido,
      dt_inicio_vigencia = data,
      dt_final_vigencia = data,
      vl_contrato = valor_reais,
      tp_instrumento_contrato,
      contrato_possui_garantia,
      vigencia_original_do_contrato,
      justificativa_contratacao,
      obs_contrato = observacao,
      tipo_instrumento_contrato,
      descricao_objeto_contrato = observacao
    ) %>% 
    left_join(empenhos_licitacao_df, by = c("codigo_contrato"))
  
  flog.info(str_glue('{compras_df %>% nrow} adaptados.'))
  flog.info(str_glue('{compras_df %>% filter(is.na(nr_licitacao)) %>% nrow} não tem licitações relacionadas.'))
  
  return(compras_df)
}
