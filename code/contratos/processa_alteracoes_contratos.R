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
#' @param alteracoes_df Dataframe de alterações de contrato
#'
#' @return Dataframe com informações das alterações dos contratos
#'   
#' @examples 
#' info_alteracoes_contratos <- processa_info_alteracoes_contratos(alteracoes_df)
#' 
#' Chave primária: 
#' (cd_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, 
#' tp_instrumento_contrato, id_evento_contrato)
processa_info_alteracoes_contratos <- function(alteracoes_df) {

  info_alteracoes_contrato <- alteracoes_df %>%
    janitor::clean_names() %>%
    dplyr::select(
      id_orgao = cd_orgao,
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
