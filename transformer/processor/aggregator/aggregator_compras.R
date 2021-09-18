library(tidyverse)
library(magrittr)
library(here)
library(futile.logger)

source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/constants.R"))

source(here::here("transformer/processor/estados/RS/licitacoes/processador_eventos_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_lotes_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_itens_contratos_rs.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_compras_rs.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_itens_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/Federal/contratos/processador_compras_federal.R"))


#' Agrupa dados de compras monitoradas pelo Tá de pé
#' 
#' As compras é uma abstração criada pelo Tá de pé para identificar as licitações que não tem 
#' contratos associados mas que tiveram fornecimento realizado.
#'
#' @param anos Array com os anos para processamento.
#' @param filtro Filtro usado para processamento.
#' @param administracao Array com a lista de estados/administrações para processar.
#' @param info_licitacoes Dados agregados de licitações (aggregator_licitacoes 
#' transformer/processor/aggregator/aggregator_licitacoes.R)
#' @param info_orgaos Dados agregados de órgãos (aggregator_orgaos 
#' transformer/processor/aggregator/aggregator_orgaos.R)
#' @return Dataframe com as compras agregadas e prontos para ir para o BD.
#' 
#' @examples 
#' compras_agregadas <- 
#' aggregator_compras(c(2020), "covid", c("PE", "RS"), 
#' info_licitacoes = aggregator_licitacoes(c(2020), "covid", c("PE", "RS")),
#' info_orgaos = aggregator_orgaos(c(2020), "covid", c("PE", "RS")))
aggregator_compras <- function(anos, filtro, administracao = c("PE", "RS"), info_licitacoes, info_orgaos) {
  
  flog.info("#### Processando agregador de compras...")
  
  if ("RS" %in% administracao) {
    compras_rs <- tryCatch({
      flog.info("# processando compras do RS...")
      flog.info("licitações encerradas...")
      licitacoes_encerradas_rs <- processa_eventos_licitacoes_rs(anos)
      
      flog.info("lotes de licitação...")
      lotes_licitacoes_rs <- processa_lotes_licitacoes_rs(anos)
      
      flog.info("preparando dados de itens de licitação e contratos...")
      itens_contrato <- processa_itens_contrato_rs(anos)
      itens_licitacao <- processa_itens_licitacoes_renamed_columns_rs()
      
      flog.info("processando compras...")
      processa_compras_rs(anos, licitacoes_encerradas_rs, lotes_licitacoes_rs, itens_licitacao, itens_contrato) %>% 
        rename(
          descricao_objeto_contrato = ds_objeto,
          tp_documento_contratado = tp_fornecedor,
          nr_documento_contratado = nr_fornecedor
        )
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de compras do RS")
      flog.error(e)
      return(tibble())
    })
  } else {
    compras_rs <- tibble()
  }
  
  if ("BR" %in% administracao) {
    compras_federal <- tryCatch({
      flog.info("# processando compras do Governo Federal...")
      processa_compras_federal(filtro)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de compras do Governo Federal")
      flog.error(e)
      return(tibble())
    })
  } else {
    compras_federal <- tibble()
  }
  
  # TODO: Compras para PE não pode ser acessada ainda pela falta de itens de licitação na base do Tome Conta
  
  if (nrow(compras_rs) == 0 && nrow(compras_federal) == 0) {
    flog.warn("Nenhum dado de compras para agregar")
    return(tibble())
  }
  
  info_compras <- bind_rows(compras_rs, compras_federal) %>%
    join_compras_e_licitacoes(info_licitacoes) %>% 
    join_compras_e_orgaos(info_orgaos) %>% 
    generate_hash_id(c("id_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade",
                       "nr_contrato", "ano_contrato", "tp_instrumento_contrato"), CONTRATO_ID) %>%
    dplyr::distinct(id_licitacao, id_contrato, .keep_all = TRUE) %>%
    dplyr::select(
      id_contrato,
      id_licitacao,
      id_orgao,
      cd_orgao,
      codigo_contrato,
      nr_contrato,
      ano_contrato,
      nm_orgao,
      nr_licitacao,
      ano_licitacao,
      cd_tipo_modalidade,
      dt_inicio_vigencia,
      vl_contrato,
      descricao_objeto_contrato,
      tp_instrumento_contrato,
      dt_inicio_vigencia,
      tipo_instrumento_contrato,
      tp_documento_contratado,
      nr_documento_contratado,
      sigla_estado,
      id_estado
    )
  
  flog.info(str_glue('{info_compras %>% filter(is.na(id_licitacao)) %>% nrow} compras não tem licitações relacionadas.'))

  return(info_compras)
}