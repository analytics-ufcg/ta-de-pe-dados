library(tidyverse)
library(magrittr)
library(here)
library(futile.logger)

source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/constants.R"))

source(here::here("transformer/processor/estados/RS/licitacoes/processador_documentos_licitacoes_rs.R"))

#' Agrupa dados de documentos de licitações monitoradas pelo Tá de pé
#'
#' @param anos Array com os anos para processamento.
#' @param info_licitacoes Dados agregados de licitações (aggregator_licitacoes 
#' transformer/processor/aggregator/aggregator_licitacoes.R)
#' @param administracao Array com a lista de estados/administrações para processar.
#' @return Dataframe as licitações agregadas e prontas para ir para o BD.
#' 
#' @examples 
#' documentos_licitacao_agregados <- 
#' aggregator_licitacoes(c(2020), c("PE", "RS"), info_licitacoes = aggregator_licitacoes(c(2020), "covid", c("PE", "RS")))
aggregator_documentos_licitacao <- function(anos, administracao = c("PE", "RS"), info_licitacoes) {

  flog.info("#### Processando agregador de documentos de licitação...")
  
  tipos_documento_licitacao_rs <- processa_tipos_documentos_licitacoes_rs()
  
  if ("RS" %in% administracao) {
    documento_licitacao_rs <- tryCatch({
      flog.info("processando de documentos de licitação do RS...")
      processa_documentos_licitacoes_rs(anos)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de de documentos de licitação do RS")
      flog.error(e)
      return(tibble())
    })
  } else {
    documento_licitacao_rs <- tibble()
  }
  
  # TODO: dados de documentos de licitação em Pernambuco ainda não foram processados.
  
  if (nrow(documento_licitacao_rs) == 0) { ## Remover quando outros dados de itens de licitação estiverem disponíveis
    flog.warn("Nenhum dado de documento de licitação para agregar")
    return(tibble())
  }
  
  
  info_documento_licitacao <- documento_licitacao_rs %>%
    join_licitacoes_e_documentos(info_licitacoes) %>%
    generate_hash_id(c("cd_orgao", "id_estado"),
                     O_ID) %>% 
    join_documento_e_tipo(tipos_documento_licitacao_rs) %>%
    generate_hash_id(c("cd_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade",
                       "cd_tipo_documento", "nome_arquivo_documento",
                       "cd_tipo_fase", "id_evento_licitacao", "tp_documento", "nr_documento"),
                     DOC_LIC_ID) %>%
    dplyr::select(id_documento_licitacao, id_licitacao, id_orgao, dplyr::everything())
  
  return(info_documento_licitacao)
}