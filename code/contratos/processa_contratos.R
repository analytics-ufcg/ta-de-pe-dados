source(here::here("code/utils/utils.R"))

#' Processa dados de contratos do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos contratos
#' 
#' @return Dataframe com informações dos contratos
#' 
#' @examples 
#' contratos <- import_contratos(c(2017, 2018, 2019))
#' 
import_contratos <- function(anos = c(2017, 2018, 2019)) {
  
  contratos <- purrr::pmap_dfr(list(anos),
                         ~ import_contratos_por_ano(..1)
  )
  
  return(contratos)
}

#' Importa dados de contratos em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação dos contratos
#'
#' @return Dataframe com informações dos contratos
#'   
#' @examples 
#' contratos <- import_contratos_por_ano()
#' 
import_contratos_por_ano <- function(ano = 2019) {
  message(paste0("Importando contratos do ano ", ano))
  contratos <- read_contratos(ano)
  
  return(contratos)
}

#' Processa dados para tabela de informações dos contratos de licitações de merenda no RS
#' 
#' @param anos Vector de inteiros com anos para captura dos contratos
#'
#' @return Dataframe com informações dos contratos
#'   
#' @examples 
#' contratos <- import_info_contratos(contratos_df)
#' 
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato)
processa_info_contratos <- function(contratos_df) {

  info_contratos <- contratos_df %>%
    janitor::clean_names() %>% 
    select(nr_contrato, ano_contrato, id_orgao = cd_orgao, nm_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade,
           tp_instrumento_contrato = tp_instrumento, nr_processo, ano_processo, tp_documento_contratado = tp_documento,
           nr_documento_contratado = nr_documento, dt_inicio_vigencia, dt_final_vigencia, vl_contrato, 
           contrato_possui_garantia = bl_garantia, vigencia_original_do_contrato = nr_dias_prazo,
           descricao_objeto_contrato = ds_objeto, justificativa_contratacao = ds_justificativa, 
           obs_contrato = ds_observacao) 
}
