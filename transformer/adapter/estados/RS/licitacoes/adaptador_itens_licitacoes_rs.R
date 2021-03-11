library(here)
library(janitor)
source(here::here('transformer/utils/read_utils.R'))
source(here::here('transformer/utils/utils.R'))

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
    dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_lote,  nr_item, 
           ds_item, qt_itens_licitacao = qt_itens, sg_unidade_medida, vl_unitario_estimado, 
           vl_total_estimado)
    
  return(info_item_licitacao)
}

#' Filtra os itens de licitação para retornar apenas os itens que foram comprados
#' em licitações de Dispensa ou Inexigibilidade
#' 
#' @param itens_licitacao_df Dataframe com itens de licitação
#' 
#' @param compras_df Dataframe com as compras feitas sem necessidade de contrato
#' 
#' @return Dataframe com informações dos itens das licitações
#'   
#' @examples 
#' info_item_licitacao_comprado <- processa_item_licitacao_comprado(itens_licitacao_df, itens_contrato, licitacoes_encerradas)
#' 
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_lote, nr_item)
#' 
processa_item_licitacao_comprado <- function(itens_licitacao_df, compras_df) {
  
  compras_alt <- compras_df %>% 
    janitor::clean_names("all_caps") %>% 
    dplyr::select(CD_ORGAO, NR_LICITACAO, ANO_LICITACAO, CD_TIPO_MODALIDADE, NR_LOTE, NR_ITEM, 
                  NR_CONTRATO, ANO_CONTRATO, TP_INSTRUMENTO = TP_INSTRUMENTO_CONTRATO)
  
  info_item_licitacao <- itens_licitacao_df %>%
    dplyr::mutate(
      VL_ITEM = dplyr::if_else(is.na(VL_UNITARIO_HOMOLOGADO) | VL_UNITARIO_HOMOLOGADO == 0, VL_UNITARIO_ESTIMADO, VL_UNITARIO_HOMOLOGADO),
      VL_TOTAL_ITEM = dplyr::if_else(is.na(VL_TOTAL_HOMOLOGADO) | VL_UNITARIO_HOMOLOGADO == 0, VL_TOTAL_ESTIMADO, VL_TOTAL_HOMOLOGADO),
      ORIGEM_VALOR = dplyr::if_else(is.na(VL_UNITARIO_HOMOLOGADO) | VL_UNITARIO_HOMOLOGADO == 0, "estimado", "homologado")
    ) %>%
    ## filtra apenas itens de licitação da modalidade de Dispensa e Inexigibilidade
    dplyr::filter(CD_TIPO_MODALIDADE %in% c("PRD", "PRI")) %>%
    ## filtra apenas os itens que foram comprados
    dplyr::inner_join(compras_alt, 
                      by = c("CD_ORGAO", "NR_LICITACAO", "ANO_LICITACAO", "CD_TIPO_MODALIDADE", "NR_LOTE", "NR_ITEM"))
  
  return(info_item_licitacao)
}
