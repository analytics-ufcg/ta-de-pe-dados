library(tidyverse)

#' Processa dados de compras realizadas em licitações de Dispensa ou Inexigibilidade. Contém ligação entre
#' as compras e os itens
#' @param licitacoes_df Dataframe com dados de licitações baixados diretamente do TSE
#' @param licitacoes_encerradas_df Dataframe com informações de licitações encerradas
#' @param lotes_df Dataframe com informações dos lotes das licitações
#' @param itens_licitacao_df Dataframe com informações dos itens das licitações
#' @param itens_contrato_df Dataframe com informações dos itens dos contratos
#' @return Dataframe com informações das compras realizadas 
#' @examples 
#' compras_itens <- 
#' adapta_compras_itens(licitacoes_df, licitacoes_encerradas_df, lotes_df, itens_licitacao_df, itens_contrato_df)
#' 
adapta_compras_itens <- function(licitacoes_df, licitacoes_encerradas_df, lotes_df, 
                                   itens_licitacao_df, itens_contrato_df) {
  licitacoes_compras <- licitacoes_encerradas_df %>% 
    dplyr::filter(cd_tipo_modalidade %in% c("PRD", "PRI"))
  
  # Preparando os dados de licitações
  # as colunas do documento_fornecedor foram escolhidas, pois quando se tratam de licitações
  # das modalidades PRD e PRI elas são de obrigatório preenchimento
  licitacoes <- .prepara_licitacoes_df(licitacoes_df)
  
  # Jutando as informações de licitação às licitações encerradas
  licitacoes_compras_nivel <- licitacoes_compras %>% 
    dplyr::left_join(licitacoes,
                     by = c("cd_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade"))
  
  ## Preparando os dados de lotes
  lotes_vencedores <- .prepara_lotes_df(lotes_df)
  
  ## Juntando os lotes às licitações
  licitacoes_lotes <- licitacoes_compras_nivel %>% 
    dplyr::left_join(lotes_vencedores,
                     by = c("cd_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade"))
  
  ## Preparando dados de itens
  itens_licitacao_filtrados <- .prepara_itens_df(itens_licitacao_df, itens_contrato_df)
  
  ## Jutando os itens aos lotes
  licitacoes_itens <- licitacoes_lotes %>% 
    dplyr::left_join(itens_licitacao_filtrados,
                     by = c("cd_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade", "nr_lote"))
  
  compras_itens <- .adapta_dataframe_compras(licitacoes_itens) %>% 
    filter(!tem_item_contrato) 
  ## apenas considera compras comoa ligação entre fornecedor e licitação nos itens de licitação que não possuem itens de contratos
  
  return(compras_itens)
}

#' Seleciona as colunas para o dataframe de licitacoes_df usados no processamento das compras
#' @param licitacoes_df Dataframe com dados de licitações baixados diretamente do TSE
#' @return Dataframe de licitações processado
#' @examples 
#' licitacoes <- .prepara_licitacoes_df(licitacoes_df)
#' 
.prepara_licitacoes_df <- function(licitacoes_df) {
  licitacoes_df %>% 
    janitor::clean_names() %>% 
    dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, ds_objeto,
                  tp_nivel_julgamento, tp_documento_fornecedor, nr_documento_fornecedor,
                  vl_estimado_licitacao = vl_licitacao, vl_homologado)
}

#' Seleciona as colunas para o dataframe de lotes_df usados no processamento das compras
#' @param lotes_df Dataframe com informações dos lotes das licitações
#' @return Dataframe de lotes processado
#' @examples 
#' lotes <- .prepara_lotes_df(lotes_df)
#' 
.prepara_lotes_df <- function(lotes_df) {
  lotes_df %>% 
    dplyr::filter(cd_tipo_modalidade %in% c("PRD", "PRI")) %>% 
    dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_lote, ds_lote,
                  tp_documento_fornecedor_lote = tp_documento_fornecedor, 
                  nr_documento_fornecedor_lote = nr_documento_fornecedor)
}

#' Seleciona as colunas para o dataframe de itens usados no processamento das compras
#' @param itens_licitacao_df Dataframe com informações dos itens das licitações
#' @param itens_contrato_df Dataframe com informações dos itens dos contratos
#' @return Dataframe de lotes processado
#' @examples 
#' itens <- .prepara_itens_df(itens_df)
#' 
.prepara_itens_df <- function(itens_licitacao_df, itens_contrato_df) {
  itens_contratos_sel <- itens_contrato_df %>%
    janitor::clean_names() %>% 
    dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_lote, nr_item, nr_contrato)
  
  itens_df <- itens_licitacao_df %>% 
    janitor::clean_names() %>%
    dplyr::filter(cd_tipo_modalidade %in% c("PRD", "PRI")) %>% 
    dplyr::left_join(itens_contratos_sel,
                     by = c("cd_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade", "nr_lote", "nr_item")) %>%
    dplyr::mutate(tem_item_contrato = dplyr::if_else(!is.na(nr_contrato),
                                                     TRUE,
                                                     FALSE)) %>% 
    dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_lote, nr_item, ds_item,
                  tp_documento_fornecedor_item = tp_documento_fornecedor, 
                  nr_documento_fornecedor_item = nr_documento_fornecedor, tem_item_contrato,
                  vl_total_homologado, vl_unitario_homologado, vl_total_estimado)
  
  return(itens_df)
}

#' Processa dataframe de compras criando as colunas que tornam a compra semelhante a um contrato
#' @param licitacoes_itens Dataframe com dados de licitações encerradas ligadas a itens de licitação e a lotes
#' @return Dataframe com informações das compras realizadas (completando as colunas necessárias)
#' @examples 
#' compras <- adapta_dataframe_compras(licitacoes_itens)
#' 
.adapta_dataframe_compras <- function(licitacoes_itens) {
  
  compras <- licitacoes_itens %>% 
    dplyr::mutate(tp_fornecedor = dplyr::case_when(
      tp_nivel_julgamento == "G" ~ tp_documento_fornecedor,
      tp_nivel_julgamento == "L" ~ tp_documento_fornecedor_lote,
      tp_nivel_julgamento == "I" ~ tp_documento_fornecedor_item,
      TRUE ~ tp_documento_fornecedor_item
    )) %>% 
    dplyr::mutate(nr_fornecedor = dplyr::case_when(
      tp_nivel_julgamento == "G" ~ nr_documento_fornecedor,
      tp_nivel_julgamento == "L" ~ nr_documento_fornecedor_lote,
      tp_nivel_julgamento == "I" ~ nr_documento_fornecedor_item,
      TRUE ~ nr_documento_fornecedor_item
    )) %>% 
    dplyr::mutate(ano_contrato = ano_licitacao,
                  tp_instrumento_contrato = "Compra",
                  tipo_instrumento_contrato = "Compra") %>%
    dplyr::mutate(nr_contrato = dplyr::if_else(is.na(nr_fornecedor),
                                               "1",
                                               paste0(nr_licitacao, nr_fornecedor)))
  
  compras_vl_contrato <- compras %>% 
    dplyr::mutate(vl_total_item = dplyr::if_else(is.na(vl_total_homologado) | vl_unitario_homologado == 0, vl_total_estimado, vl_total_homologado)) %>% 
    dplyr::group_by(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato) %>% 
    dplyr::mutate(vl_contrato = sum(vl_total_item)) %>% 
    dplyr::ungroup()
  
  return(compras_vl_contrato)
}
