source(here("transformer/adapter/estados/RS/contratos/adaptador_compras_rs.R"))
source(here::here("transformer/adapter/estados/RS/licitacoes/adaptador_licitacoes_rs.R"))


#' Processa dados de compras do estado do Rio Grande do Sul para um conjunto de filtros
#' 
#' @param anos Vector de inteiros com anos para captura das compras
#' 
#' @return Dataframe com informações processadas das compras
#' 
#' @examples 
#' compras_rs <- processa_compras_rs(2019, licitacoes_encerradas_rs,
# lotes_licitacoes_rs, itens_licitacao, itens_contrato)
processa_compras_rs <- function(anos, licitacoes_encerradas_rs,
                                   lotes_licitacoes_rs, itens_licitacao, itens_contrato) {
  licitacoes_raw <- import_licitacoes(anos)
  
  compras_rs <- adapta_compras_itens(licitacoes_raw, licitacoes_encerradas_rs,
                                     lotes_licitacoes_rs, itens_licitacao, itens_contrato) %>% 
    add_info_estado(sigla_estado = "RS", id_estado = "43")
  
  return(compras_rs)
}

