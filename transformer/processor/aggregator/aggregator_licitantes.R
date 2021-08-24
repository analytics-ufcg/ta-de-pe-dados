library(tidyverse)
library(magrittr)
library(here)
library(futile.logger)

source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/constants.R"))

source(here::here("transformer/processor/estados/RS/licitacoes/processador_licitantes_rs.R"))


#' Agrupa dados de licitantes monitorados pelo Tá de pé
#'
#' @param anos Array com os anos para processamento.
#' @param administracao Array com a lista de estados/administrações para processar.
#' @param info_licitacoes Dados agregados de licitações (aggregator_licitacoes 
#' transformer/processor/aggregator/aggregator_licitacoes.R)
#' @return Dataframe com os licitantes agregados e prontos para ir para o BD.
#' 
#' @examples 
#' licitantes <- aggregator_licitantes(c(2020), info_licitacoes = aggregator_licitacoes(c(2020), "covid", c("PE", "RS")))
aggregator_licitantes <- function(anos, administracao, info_licitacoes) {
  
  flog.info("#### Processando agregador de licitantes...")
  
  if ("RS" %in% administracao) {
    licitantes_rs <- tryCatch({
      flog.info("processando licitantes do RS...")
      processa_licitantes_rs(anos)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de licitantes do RS")
      flog.error(e)
      return(tibble())
    })
  } else {
    licitantes_rs <- tibble()
  }
  
  # TODO: Dados de licitantes para PE
  
  if (nrow(licitantes_rs) == 0) {
    flog.warn("Nenhum dado de licitante para agregar")
    return(tibble())
  }
  
  info_licitantes <- tryCatch({
    join_licitante_e_licitacao(
      licitantes_rs,
      info_licitacoes %>%
        dplyr::select(id_estado, id_orgao, cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, id_licitacao)
    ) %>%
      generate_hash_id(c("id_licitacao", "tp_documento_licitante", "nr_documento_licitante"), LICITANTE_ID) %>%
      dplyr::select(id_licitante, id_estado, id_orgao, id_licitacao, dplyr::everything())
  }, error = function(e) {
    flog.error("Ocorreu um erro ao agregar os dados de licitantes")
    flog.error(e)
    return(tibble())
  })
  
  return(info_licitantes)
}