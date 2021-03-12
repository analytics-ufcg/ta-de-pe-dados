source(here::here("transformer/utils/read_utils.R"))

#' Importa dados de contratos em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação das alterações dos contratos
#'
#' @return Dataframe com informações das alterações dos contratos
#'   
#' @examples 
#' alteracoes_contratos <- import_alteracoes_contratos_por_ano(2019)
#' 
import_alteracoes_contratos_por_ano <- function(ano = 2019) {
  message(paste0("Importando alterações dos contratos do ano ", ano))

  alteracoes_contratos <- read_alteracoes_contratos(ano)
  
  return(alteracoes_contratos)
}

#' Processa dados de alterações de contratos do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura das alterações de contratos
#' 
#' @return Dataframe com informações das alterações de contratos
#' 
#' @examples 
#' contratos <- import_contratos(c(2017, 2018, 2019, 2020))
#' 
import_alteracoes_contratos <- function(anos = c(2017, 2018, 2019, 2020)) {
  
  alteracoes_contrato <- purrr::pmap_dfr(list(anos),
                               ~ import_alteracoes_contratos_por_ano(..1)
  )
  
  return(alteracoes_contrato)
}

#' Processa dados para a tabela de alterações dos contratos no Rio Grande do Sul
#'
#' @param alteracoes_df Dataframe de alterações de contrato
#'
#' @return Dataframe com informações das alterações dos contratos
#'   
#' @examples 
#' info_alteracoes_contratos <- adapta_info_alteracoes_contratos(alteracoes_df)
#' 
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, 
#' tp_instrumento_contrato, id_evento_contrato, cd_tipo_operacao)
adapta_info_alteracoes_contratos <- function(alteracoes_df) {

  info_alteracoes_contrato <- alteracoes_df %>%
    janitor::clean_names() %>%
    dplyr::select(
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
      ds_justificativa
    ) %>% 
    dplyr::filter(!is.na(ano_licitacao))
  
  return(info_alteracoes_contrato)
}
