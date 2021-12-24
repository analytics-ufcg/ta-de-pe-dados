library(tidyverse)
library(magrittr)
library(here)
library(futile.logger)

source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/constants.R"))

source(here::here("transformer/processor/estados/RS/contratos/processador_contratos_rs.R"))
source(here::here("transformer/processor/estados/PE/contratos/processador_contratos_pe.R"))

#' Agrupa dados de contratos monitorados pelo Tá de pé
#'
#' @param anos Array com os anos para processamento.
#' @param administracao Array com a lista de estados/administrações para processar.
#' @param info_licitacoes Dados agregados de licitações (aggregator_licitacoes 
#' transformer/processor/aggregator/aggregator_licitacoes.R)
#' @return Dataframe com os contratos agregados e prontos para ir para o BD.
#' 
#' @examples 
#' contratos_agregados <- 
#' aggregator_contratos(c(2020), c("PE", "RS"), info_licitacoes = aggregator_licitacoes(c(2020), "covid", c("PE", "RS")))
aggregator_contratos <- function(anos, administracao = c("PE", "RS"), info_licitacoes) {
  
  flog.info("#### Processando agregador de contratos..")
  
  if ("RS" %in% administracao) {
    contratos_rs <- tryCatch({
      flog.info("processando contratos do RS...")
      processa_contratos_rs(anos)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de contratos do RS")
      flog.error(e)
      return(tibble())
    })
  } else {
    contratos_rs <- tibble()
  }
  
  if ("PE" %in% administracao) {
    contratos_pe <- tryCatch({
      flog.info("processando contratos do PE...")
      processa_contratos_pe()
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de contratos do PE")
      flog.error(e)
      return(tibble())
    })
  } else {
    contratos_pe <- tibble()
  }

  info_contratos <- bind_rows(contratos_pe, contratos_rs)

  if (nrow(info_contratos) == 0) {
    flog.warn("Nenhum dado de contrato para agregar!")
    empty_info_contrato <- tibble(
      id_contrato = character(),
      id_estado = character(),
      id_orgao = character(),
      id_licitacao = character(),
      codigo_contrato = character(),
      nr_contrato = character(),
      ano_contrato = integer(),
      cd_orgao = character(),
      nm_orgao = character(),
      nr_processo = character(),
      ano_processo = character(),
      tp_documento_contratado = character(),
      nr_documento_contratado = character(),
      dt_inicio_vigencia = as.Date(character()),
      dt_final_vigencia = as.Date(character()),
      vl_contrato = numeric(),
      descricao_objeto_contrato = character(),
      nr_licitacao = character(),
      sigla_estado = character(),
      tp_instrumento_contrato = character(),
      contrato_possui_garantia = character(),
      vigencia_original_do_contrato = integer(),
      justificativa_contratacao = character(),
      obs_contrato = character(),
      tipo_instrumento_contrato = character(),
      ano_licitacao = integer(),
      cd_tipo_modalidade = character(),
      tem_alteracoes = logical()
    )
    return(empty_info_contrato)
  }
  
  info_contratos <- info_contratos %>% 
    join_contrato_e_licitacao(info_licitacoes %>%
                                dplyr::select(cd_orgao,
                                              nr_licitacao,
                                              ano_licitacao,
                                              cd_tipo_modalidade,
                                              id_licitacao, 
                                              id_orgao,
                                              id_estado)) %>% 
    generate_hash_id(c("id_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade",
                       "nr_contrato", "ano_contrato", "tp_instrumento_contrato"), CONTRATO_ID) %>%
    dplyr::select(id_contrato, id_estado, id_orgao, id_licitacao, codigo_contrato, nr_contrato,
                  ano_contrato, cd_orgao, nm_orgao, nr_processo, ano_processo, tp_documento_contratado,
                  nr_documento_contratado, dt_inicio_vigencia, dt_final_vigencia, vl_contrato,
                  descricao_objeto_contrato, nr_licitacao, sigla_estado, tp_instrumento_contrato, contrato_possui_garantia,
                  vigencia_original_do_contrato, justificativa_contratacao, obs_contrato, tipo_instrumento_contrato, 
                  ano_licitacao, cd_tipo_modalidade, tem_alteracoes)
  
  return(info_contratos)
}