library(tidyverse)
library(magrittr)
library(here)
library(futile.logger)

source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/constants.R"))

source(here::here("transformer/processor/estados/RS/licitacoes/processador_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/PE/licitacoes/processador_licitacoes_pe.R"))
source(here::here("transformer/processor/estados/Federal/licitacoes/processador_licitacoes_federal.R"))

#' Agrupa dados de licitações monitoradas pelo Tá de pé
#'
#' @param anos Array com os anos para processamento.
#' @param filtro Filtro usado para filtrar as licitações.
#' @param administracao Array com a lista de estados/administrações para processar.
#' @return Dataframe as licitações agregadas e prontas para ir para o BD.
#' 
#' @examples 
#' licitacoes_agregadas <- aggregator_licitacoes(c(2020), "covid", c("PE", "RS"))
aggregator_licitacoes <- function(anos, filtro, administracao = c("PE", "RS")) {

  flog.info("#### Processando agregador de licitações...")
  
  if ("RS" %in% administracao) {
    licitacoes_rs <- tryCatch({
      flog.info("processando licitações do RS...")
      processa_licitacoes_rs(anos, filtro)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de licitações do RS")
      flog.error(e)
      return(tibble())
    })
  } else {
    licitacoes_rs <- tibble()
  }
  
  if ("PE" %in% administracao) {
    licitacoes_pe <- tryCatch({
      flog.info("processando licitações do PE...")
      processa_licitacoes_pe(filtro)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de licitações do PE")
      flog.error(e)
      return(tibble())
    })
  } else {
    licitacoes_pe <- tibble()
  }

  if ("BR" %in% administracao) {
    licitacoes_federais <- tryCatch({
      flog.info("processando licitações do Governo Federal (BR)...")
      processa_licitacoes_federal(filtro)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de licitações do Governo Federal (BR)")
      flog.error(e)
      return(tibble())
    })
  } else {
    licitacoes_federais <- tibble()
  }
  
  licitacoes_falsos_positivos <- readr::read_csv(here::here("transformer/utils/files/licitacoes_falsos_positivos.csv"))
  
  info_licitacoes <- bind_rows(licitacoes_rs,
                               licitacoes_pe,
                               licitacoes_federais)  %>% 
    generate_hash_id(c("cd_orgao", "id_estado"),
                     O_ID) %>% 
    distinct() %>% 
    generate_hash_id(c("id_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade"),
                     L_ID) %>%
    dplyr::select(id_licitacao, id_estado, id_orgao, cd_orgao, nm_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade,
                  permite_subcontratacao, tp_fornecimento, descricao_objeto, vl_estimado_licitacao, data_abertura, 
                  data_homologacao, data_adjudicacao, vl_homologado, tp_licitacao, assunto, tipo_licitacao, 
                  tipo_modalidade_licitacao, sigla_estado) %>%
    dplyr::filter(!id_licitacao %in% (licitacoes_falsos_positivos %>% pull(id_licitacao)))
  
  return(info_licitacoes)
}