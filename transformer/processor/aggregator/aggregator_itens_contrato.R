library(tidyverse)
library(magrittr)
library(here)
library(futile.logger)

source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/constants.R"))

source(here::here("transformer/processor/estados/Federal/contratos/processador_itens_compras_federal.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_eventos_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_lotes_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_itens_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_itens_contratos_rs.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_compras_rs.R"))
source(here::here("transformer/processor/estados/PE/contratos/processador_itens_contratos_pe.R"))
source(here::here("transformer/processor/estados/PE/licitacoes/processador_licitacoes_pe.R"))
source(here::here("transformer/processor/estados/PE/contratos/processador_contratos_pe.R"))

#' Agrupa dados de itens de contrato monitorados pelo Tá de pé
#'
#' @param anos Array com os anos para processamento.
#' @param filtro Filtro usado para filtrar as licitações.
#' @param administracao Array com a lista de estados/administrações para processar.
#' @param info_licitacoes Dados agregados de licitações (aggregator_licitacoes 
#' transformer/processor/aggregator/aggregator_licitacoes.R)
#' @param info_contratos Dados agregados de contratos (aggregator_contratos 
#' transformer/processor/aggregator/aggregator_contratos.R)
#' @param info_orgaos Dados agregados de órgãos (aggregator_orgaos 
#' transformer/processor/aggregator/aggregator_orgaos.R)
#' @param info_item_licitacao Dados agregados de itens de licitação (aggregator_itens_licitacao 
#' transformer/processor/aggregator/aggregator_itens_licitacao.R)
#' @return Dataframe com os itens de contrato agregados e prontos para ir para o BD.
#' 
#' @examples 
#' info_orgaos = aggregator_orgaos(c(2020), "covid", c("PE", "RS", "BR"))
#' info_licitacoes = aggregator_licitacoes(c(2020), "covid", c("PE", "RS", "BR"))
#' info_contratos = aggregator_contratos(c(2020), c("PE", "RS", "BR"), info_licitacoes)
#' info_compras = aggregator_compras(c(2020), "covid", c("PE", "RS", "BR"), info_licitacoes, info_orgaos)
#' info_contratos = bind_rows(info_contratos, info_compras)
#' info_item_licitacao = aggregator_itens_licitacao(c(2020), c("PE", "RS", "BR"), info_licitacoes)
#' 
#' itens_contrato_agregado <- 
#' aggregator_itens_contrato(c(2020), "covid", c("PE", "RS", "BR"), 
#' info_licitacoes,
#' info_contratos,
#' info_orgaos,
#' info_item_licitacao)
aggregator_itens_contrato <- function(anos, filtro, administracao = c("PE", "RS", "BR"), info_licitacoes, info_contratos, info_orgaos, info_item_licitacao) {
    
  flog.info("#### Processando agregador de itens de contrato..")
  
  if ("RS" %in% administracao) {
    itens_contratos_rs <- tryCatch({
      flog.info("# processando itens de contrato do RS...")
      
      flog.info("itens de licitações...")
      itens_licitacao_rs <- processa_itens_licitacoes_rs(anos)
      
      flog.info("licitações encerradas...")
      licitacoes_encerradas_rs <- processa_eventos_licitacoes_rs(anos)
      
      flog.info("lotes de licitação...")
      lotes_licitacoes_rs <- processa_lotes_licitacoes_rs(anos)
      
      flog.info("preparando dados de itens de licitação e contratos...")
      itens_contrato <- processa_itens_contrato_rs(anos)
      itens_licitacao <- processa_itens_licitacoes_renamed_columns_rs()
      
      flog.info("processando compras...")
      compras_rs <- processa_compras_rs(anos, licitacoes_encerradas_rs, lotes_licitacoes_rs, itens_licitacao, itens_contrato)
      
      flog.info("itens com contratos...")
      itens_contrato <- processa_itens_contratos_renamed_columns_rs(itens_contrato)
      
      flog.info("processando itens sem contratos...")
      itens_comprados <- processa_item_licitacao_comprados_rs(anos, compras_rs, itens_contrato)
      
      processa_todos_itens_comprados(
        itens_comprados,
        itens_licitacao_rs %>%
          select(
            "ds_item",
            "sg_unidade_medida",
            "cd_orgao",
            "ano_licitacao",
            "nr_licitacao",
            "cd_tipo_modalidade",
            "nr_lote",
            "nr_item"
          )
      )
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de itens de contrato do RS")
      flog.error(e)
      return(tibble())
    })
  } else {
    itens_contratos_rs <- tibble()
  }
  
  if ("PE" %in% administracao) {
    itens_contratos_pe <- tryCatch({
      flog.info("# processando itens de contrato do PE...")
      licitacoes_pe <- processa_licitacoes_pe(filtro)
      contratos_pe <- processa_contratos_pe()
      processa_itens_contrato_pe(contratos_pe, licitacoes_pe)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de itens de contrato do PE")
      flog.error(e)
      return(tibble())
    })
  } else {
    itens_contratos_pe <- tibble()
  }

  if ("BR" %in% administracao) {
    itens_contratos_br <- tryCatch({
      flog.info("# processando itens de contrato do Governo Federal(BR)...")
      processa_itens_compras_federal()
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de itens de contrato do Governo Federal(BR)")
      flog.error(e)
      return(tibble())
    })
  } else {
    itens_contratos_br <- tibble()
  }
    
  if (dplyr::bind_rows(itens_contratos_rs, itens_contratos_pe, itens_contratos_br) %>% nrow() == 0) {
    flog.warn("Nenhum dado de item de contrato para agregar!")
    return(tibble())
  }

  tryCatch({
    info_item_contrato <- dplyr::bind_rows(itens_contratos_rs, itens_contratos_pe, itens_contratos_br) %>%
      left_join(info_orgaos %>% select(id_orgao, cd_orgao, id_estado),
                by = c("cd_orgao", "id_estado")) %>%
      join_contratos_e_itens(info_contratos %>%
                               dplyr::select(dt_inicio_vigencia, id_contrato, id_licitacao,
                                             codigo_contrato, cd_orgao, nr_licitacao, ano_licitacao,
                                             cd_tipo_modalidade, nr_contrato, ano_contrato, 
                                             tp_instrumento_contrato, id_estado)) %>%
      generate_hash_id(c("id_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade", "nr_contrato", "ano_contrato",
                         "tp_instrumento_contrato", "nr_lote", "nr_item"), ITEM_CONTRATO_ID) %>%
      join_itens_contratos_e_licitacoes(info_item_licitacao) %>%
      dplyr::ungroup() %>%
      dplyr::select(id_item_contrato, id_contrato, id_orgao, cd_orgao, id_licitacao, id_item_licitacao, dplyr::everything()) %>%
      create_categoria() %>%
      split_descricao() %>%
      dplyr::ungroup() %>%
      marca_servicos() %>% 
      mutate(valor_calculado = NA) %>% 
      select(id_item_contrato, id_contrato, id_orgao, cd_orgao, id_licitacao, id_item_licitacao, nr_lote, 
             nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato, 
             nr_item, qt_itens_contrato, vl_item_contrato, vl_total_item_contrato, origem_valor, tem_inconsistencia,
             sigla_estado, id_estado, dt_inicio_vigencia, ds_item, 
             sg_unidade_medida, categoria, language, ds_1, ds_2, ds_3, servico, valor_calculado)
  }, error = function(e) {
    flog.error("Ocorreu um erro durante a agregação dos itens de contrato")
    flog.error(e)
    info_item_contrato <- tibble()
  })

  erros <- info_item_contrato %>% filter(id_item_contrato %in% c('c72ce79803d2c6f29902be96acb3bcaa', '92afe971d9649d230b465a85b8b4a1d5'))
  flog.warn("==========================================")
  #  print(contrato)
  #  flog.warn("==========================================")
  print(sapply(info_item_contrato, class))
  flog.warn("==========================================")
  print(erros)
  #  readline(prompt="Press [enter] to continue")
    
  return(info_item_contrato)
}