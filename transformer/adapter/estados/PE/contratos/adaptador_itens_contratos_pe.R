source(here::here("transformer/utils/read_utils.R"))

#' Importa dados de itens dos contratos do estado de Pernambuco
#' 
#' @return Dataframe com informações dos itens dos contratos
#'   
#' @examples 
#' itens_contrato_pe <- import_itens_contrato_pe(2019)
#' 
import_itens_contrato_pe <- function() {
  message("Importando itens de contrato")
  itens_contrato_pe <- read_itens_contratos_pe()
  
  return(itens_contrato_pe)
}

#' Processa dados para a tabela de informações dos itens dos contratos de PE
#' 
#' @param itens_contrato_pe_df Dataframe de itens de contrato
#'
#' @return Dataframe com informações dos itens dos contratos
#'   
#' @examples 
#' info_item_contrato_pe <- adapta_info_itens_contratos_pe(itens_contrato_pe_df, contratos_pe_df, licitacoes_pe_df)
#'
adapta_info_itens_contratos_pe <- function(itens_contrato_pe_df, contratos_pe_df, licitacoes_pe_df) {
  info_itens_contratos_pe <- itens_contrato_pe_df %>%
    janitor::clean_names() %>% 
    mutate(nr_lote = NA_integer_) %>% 
    rename(
      codigo_contrato = codigo_contrato_original,
      nr_item = codigo_item,
      qt_itens_contrato = quantidade,
      vl_item_contrato = preco_unitario,
      vl_total_item_contrato = preco_total,
      ds_item = descricao,
      sg_unidade_medida = unidade
    ) %>% 
    left_join(contratos_pe_df %>% select(codigo_contrato,
                                         cd_orgao, 
                                         nr_licitacao, 
                                         nr_contrato,
                                         ano_contrato,
                                         tp_instrumento_contrato),
              by = c("codigo_contrato")) %>% 
    left_join(licitacoes_pe_df %>% select(nr_licitacao,
                                          ano_licitacao,
                                          cd_tipo_modalidade),
              by = c("nr_licitacao")) %>%
    dplyr::mutate(origem_valor = 'contrato')  %>%
    mutate(nr_item = as.integer(nr_item),
      qt_itens_contrato = as.double(qt_itens_contrato),
      vl_item_contrato = as.double(vl_item_contrato),
      vl_total_item_contrato = as.double(vl_total_item_contrato)
    )
  
  #faltaram:
  #nr_lote
  #tp_instrumento_contrato
  
  return(info_itens_contratos_pe)
  
  
  
}