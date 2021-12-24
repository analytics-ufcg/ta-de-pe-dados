library(tidyverse)
library(magrittr)
library(here)
library(futile.logger)

source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/constants.R"))

source(here::here("transformer/processor/estados/RS/licitacoes/processador_itens_licitacoes_rs.R"))

#' Agrupa dados de itens de licitação monitorados pelo Tá de pé
#'
#' @param anos Array com os anos para processamento.
#' @param administracao Array com a lista de estados/administrações para processar.
#' @param info_licitacoes Dados agregados de licitações (aggregator_licitacoes 
#' transformer/processor/aggregator/aggregator_licitacoes.R)
#' @return Dataframe com os itens de licitação agregados e prontas para ir para o BD.
#' 
#' @examples 
#' itens_licitacao_agregados <- 
#' aggregator_itens_licitacao(c(2020), c("PE", "RS"), info_licitacoes = aggregator_licitacoes(c(2020), "covid", c("PE", "RS")))
aggregator_itens_licitacao <- function(anos, administracao = c("PE", "RS"), info_licitacoes) {
  
  flog.info("#### Processando agregador de itens de licitação...")
  
  if ("RS" %in% administracao) {
    itens_licitacao_rs <- tryCatch({
      flog.info("processando itens de licitação do RS...")
      processa_itens_licitacoes_rs(anos)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de itens de licitação do RS")
      flog.error(e)
      return(tibble())
    })
  } else {
    itens_licitacao_rs <- tibble()
  }
  
  
  # TODO: processar dados de itens de licitação em PE (Não disponível ainda no Tome Conta)
  
  if (nrow(itens_licitacao_rs) == 0) { ## Remover quando outros dados de itens de licitação estiverem disponíveis
    flog.warn("Nenhum dado de itens de licitação para agregar")
    return(tibble())
  }
  
  info_item_licitacao <- itens_licitacao_rs %>%
    join_licitacoes_e_itens(info_licitacoes) %>%
    generate_hash_id(c("cd_orgao", "id_estado"),
                     O_ID) %>%
    distinct() %>% 
    generate_hash_id(c("cd_orgao", "ano_licitacao", "nr_licitacao",
                       "cd_tipo_modalidade", "nr_lote", "nr_item"),
                     I_ID) %>%
    dplyr::select(id_item, id_licitacao, id_orgao, dplyr::everything())
  
  return(info_item_licitacao)
}
