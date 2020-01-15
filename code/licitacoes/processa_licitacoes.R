#' Importa dados de licitações em um ano específico para o estado do Rio Grande do Sul
#' @param ano Inteiro com o ano para recuperação das licitações
#' @return Dataframe com informações das licitações
#' @examples 
#' licitacoes <- import_licitacoes_por_ano(2019)
#' 
import_licitacoes_por_ano <- function(ano) {
  message(paste0("Importando licitações do ano ", ano))
  licitacoes <- readr::read_csv(here::here(paste0("data/licitacoes/", ano, "/licitacao.csv")), 
                         col_types = list(
                           .default = readr::col_character(),
                           ANO_LICITACAO = readr::col_integer(),
                           ANO_PROCESSO = readr::col_integer(),
                           DT_AUTORIZACAO_ADESAO = readr::col_datetime(format = ""),
                           ANO_LICITACAO_ORIGINAL = readr::col_integer(),
                           DT_ATA_REGISTRO_PRECO = readr::col_datetime(format = ""),
                           PC_TAXA_RISCO = readr::col_double(),
                           DT_INICIO_INSCR_CRED = readr::col_datetime(format = ""),
                           DT_FIM_INSCR_CRED = readr::col_datetime(format = ""),
                           DT_INICIO_VIGEN_CRED = readr::col_datetime(format = ""),
                           DT_FIM_VIGEN_CRED = readr::col_datetime(format = ""),
                           VL_LICITACAO = readr::col_double(),
                           DT_ABERTURA = readr::col_datetime(format = ""),
                           DT_HOMOLOGACAO = readr::col_datetime(format = ""),
                           DT_ADJUDICACAO = readr::col_datetime(format = ""),
                           VL_HOMOLOGADO = readr::col_double(),
                           PC_TX_ESTIMADA = readr::col_double(),
                           PC_TX_HOMOLOGADA = readr::col_double()
                           
                         ))
  
  return(licitacoes)
}