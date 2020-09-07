source(here::here("code/utils/read_utils.R"))

#' Renomeia as colunas repetidas do dataframe de licitantes
#' 
#' @param licitantes Dataframe de licitantes de licitações
#' 
#' @return 
#' 
rename_duplicate_columns_licitantes <- function(licitantes) {
  licitantes <- licitantes %>% 
    dplyr::rename(TP_DOCUMENTO_LICITANTE = TP_DOCUMENTO,
           NR_DOCUMENTO_LICITANTE = NR_DOCUMENTO,
           TP_DOCUMENTO_REPRES = TP_DOCUMENTO_1,
           NR_DOCUMENTO_REPRES = NR_DOCUMENTO_1)
  
  return(licitantes)
}

#' Processa dados de licitantes do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos licitantes
#' 
#' @return Dataframe com informações dos licitantes
#' 
#' @examples 
#' licitantes <- import_licitantes(c(2017, 2018, 2019, 2020))
#' 
import_licitantes <- function(anos = c(2017, 2018, 2019, 2020)) {
  
  licitantes <- purrr::pmap_dfr(list(anos),
                                ~ import_licitantes_por_ano(..1)
  )
  
  return(licitantes)
}

#' Importa dados de licitantes em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação dos licitantes
#'
#' @return Dataframe com informações dos licitantes
#'   
#' @examples 
#' licitantes <- import_licitantes_por_ano(2019)
#' 
import_licitantes_por_ano <- function(ano = 2019) {
  message(paste0("Importando licitantes do ano ", ano))
  licitantes <- read_licitantes(ano)
  
  return(licitantes)
}

#' Processa dados de licitantes de licitações do Rio Grande do Sul
#' 
#' @param licitantes_df Dataframe de licitantes
#'
#' @return Dataframe com informações tratadas dos licitantes
#'   
#' @examples 
#' licitantes <- processa_info_licitantes(licitantes_df)
#' 
#' Chave primária:
#' (cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, tp_documento_licitante, nr_documento_licitante)
#' 
processa_info_licitantes <- function(licitantes_df) {
  licitantes <- licitantes_df %>% 
    rename_duplicate_columns_licitantes() %>% 
    janitor::clean_names() %>% 
    dplyr::select(id_orgao = cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, tp_documento_licitante,
           nr_documento_licitante, tp_documento_repres, nr_documento_repres, tp_condicao,
           tp_resultado_habilitacao, bl_beneficio_micro_epp)
  
  return(licitantes)
}
