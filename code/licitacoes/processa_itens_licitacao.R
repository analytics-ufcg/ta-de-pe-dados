library(here)
library(janitor)
source(here::here('code/utils/read_utils.R'))

#' Renomeia as colunas repetidas do dataframe de itens
#' @param itens Dataframe de itens das licitações
#' @return Dataframe com nome das colunas de acordo Manual do leiaute do e-Validador 
rename_duplicate_columns <- function(itens) {
  names(itens)[names(itens) == 'TP_DOCUMENTO'] <- 'TP_DOCUMENTO_VENCEDOR'
  names(itens)[names(itens) == 'NR_DOCUMENTO'] <- 'NR_DOCUMENTO_VENCEDOR'
  names(itens)[names(itens) == 'TP_DOCUMENTO_1'] <- 'TP_DOCUMENTO_FORNECEDOR'
  names(itens)[names(itens) == 'NR_DOCUMENTO_1'] <- 'NR_DOCUMENTO_FORNECEDOR'
  itens
}

#' Importa itens das licitações de um ano específico para o estado do Rio Grande do Sul
#' @param ano Inteiro com o ano para recuperação dos itens
#' @return Dataframe com informações dos itens das licitações
#' @examples 
#' itens <- import_itens_licitacao_por_ano(2019)
import_itens_licitacao_por_ano <- function(ano) {
  message(paste0("Importando itens das licitações do ano ", ano))
  
  itens <- read_itens(ano)
  
  return(itens)
}

#' Processa dados de itens das licitações do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos itens das licitações
#' 
#' @return Dataframe com informações dos itens das licitações
#' 
#' @examples 
#' itens_licitacao <- import_itens_licitacao(c(2017, 2018, 2019))
#' 
import_itens_licitacao <- function(anos = c(2017, 2018, 2019)) {
  
  itens_licitacao <- purrr::pmap_dfr(list(anos),
                         ~ import_itens_licitacao_por_ano(..1)
  )
  
  return(itens_licitacao)
}

#' Processa dados para a tabela de informações dos itens das licitações
#' 
#' @param anos Vector de inteiros com anos para captura dos itens das licitações
#'
#' @return Dataframe com informações dos itens das licitações
#'   
#' @examples 
#' info_item_licitacao <- processa_info_item_licitacao(anos = c(2017, 2018, 2019))
#' 
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_lote, nr_item)
#' 
processa_info_item_licitacao <- function(itens_licitacao) {
  
  info_item_licitacao <- itens_licitacao %>% 
    rename_duplicate_columns() %>% 
    janitor::clean_names() %>%
    dplyr::select(id_orgao = cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_lote,  nr_item, 
           ds_item, qt_itens_licitacao = qt_itens, sg_unidade_medida, vl_unitario_estimado, 
           vl_total_estimado)
    
  return(info_item_licitacao)
}

#' Filtra os itens de licitação para retornar apenas os itens que foram comprados
#' em licitações de Dispensa ou Inexigibilidade
#' 
#' @param itens_licitacao_df Dataframe com itens de licitação
#' 
#' @param itens_contrato Dataframe com itens de contrato
#' 
#' @param licitacoes_encerradas Dataframe com as licitações encerradas
#'
#' @return Dataframe com informações dos itens das licitações
#'   
#' @examples 
#' info_item_licitacao_comprado <- processa_item_licitacao_comprado(itens_licitacao_df, itens_contrato, licitacoes_encerradas)
#' 
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_lote, nr_item)
#' 
processa_item_licitacao_comprado <- function(itens_licitacao_df, itens_contrato, licitacoes_encerradas) {
  
  info_item_licitacao <- itens_licitacao_df %>%
    dplyr::mutate(NR_CONTRATO = 1, ANO_CONTRATO = ANO_LICITACAO, TP_INSTRUMENTO = NA,
      VL_ITEM = dplyr::if_else(is.na(VL_UNITARIO_HOMOLOGADO) | VL_UNITARIO_HOMOLOGADO == 0, VL_UNITARIO_ESTIMADO, VL_UNITARIO_HOMOLOGADO),
      VL_TOTAL_ITEM = dplyr::if_else(is.na(VL_TOTAL_HOMOLOGADO) | VL_UNITARIO_HOMOLOGADO == 0, VL_TOTAL_ESTIMADO, VL_TOTAL_HOMOLOGADO),
      ORIGEM_VALOR = dplyr::if_else(is.na(VL_UNITARIO_HOMOLOGADO) | VL_UNITARIO_HOMOLOGADO == 0, "estimado", "homologado")
    ) %>%
    ## filtra apenas itens de licitação da modalidade de Dispensa e Inexigibilidade
    dplyr::filter(CD_TIPO_MODALIDADE %in% c("PRD", "PRI")) %>%
    
    ## filtra apenas itens de licitação que não possuem itens de contrato associados
    dplyr::anti_join(itens_contrato, 
                     by = c("CD_ORGAO", "NR_LICITACAO", "ANO_LICITACAO", "CD_TIPO_MODALIDADE")) %>%
    
    ## filtra apenas licitacoes que tiveram o evento de encerramento
    dplyr::inner_join(licitacoes_encerradas %>%
                        distinct(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade),
                      by = c("CD_ORGAO" = "cd_orgao",
                             "NR_LICITACAO" = "nr_licitacao", 
                             "ANO_LICITACAO" = "ano_licitacao", 
                             "CD_TIPO_MODALIDADE" = "cd_tipo_modalidade"))
  
  return(info_item_licitacao)
}
