source(here::here("transformer/utils/read_utils.R"))

#' Processa dados de documentos das licitações do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos documentos das licitações
#' 
#' @return Dataframe com informações dos documentos das licitações
#' 
#' @examples 
#' documentos_licitacoes <- import_documentos_licitacoes(c(2018,2019,2020))
#' 
import_documentos_licitacoes <- function(anos) {
  
  documentos_licitacoes <- purrr::pmap_dfr(list(anos),
                                           ~ import_documentos_licitacoes_por_ano(..1)
  )
  
  return(documentos_licitacoes)
}

#' Importa dados dos documentos das licitações em um ano específico para o estado do Rio Grande do Sul
#' @param ano Inteiro com o ano para recuperação dos documentos das licitações
#' @return Dataframe com informações dos documentos das licitações
#' @examples 
#' documentos_licitacoes <- import_documentos_licitacoes_por_ano(2019)
#' 
import_documentos_licitacoes_por_ano <- function(ano) {
  message(paste0("Importando Documentos das licitações do ano ", ano))
  documentos_licitacoes <- read_documentos_licitacoes(ano)
  
  return(documentos_licitacoes)
}

#' Prepara dados para tabela de documentos das licitações
#'
#' @return Dataframe com informações dos documentos das licitações
#'   
#' @examples 
#' info_documentos_licitacoes <- processa_info_documentos_licitacoes(import_documentos_licitacoes(c(2019)))
#' 
#' Chave primária:
#' (id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, cd_tipo_documento, nome_arquivo_documento, 
#' cd_tipo_fase, id_evento_licitacao, tp_documento, nr_documento)
#' 
processa_info_documentos_licitacoes <- function(documentos_licitacoes_df) {
  
  info_documentos_licitacoes <- documentos_licitacoes_df %>%
    janitor::clean_names() %>%
    dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, cd_tipo_documento, 
                  nome_arquivo_documento, cd_tipo_fase, id_evento_licitacao, tp_documento, nr_documento,
                  arquivo_timestamp, arquivo_url_download)
  
  return(info_documentos_licitacoes)
}

