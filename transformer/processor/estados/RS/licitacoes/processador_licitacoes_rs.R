source(here::here("transformer/adapter/estados/RS/licitacoes/adaptador_licitacoes_rs.R"))
source(here::here("transformer/adapter/estados/RS/licitacoes/adaptador_tipos_licitacoes_rs.R"))
source(here::here("transformer/adapter/estados/RS/licitacoes/adaptador_tipos_modalidades_licitacoes_rs.R"))

#' Processa dados de licitações do estado do Rio Grande do Sul para um conjunto de filtros
#' 
#' @param anos Vector de inteiros com anos para captura das licitações
#' @param filtro Pode ser merenda ou covid
#' 
#' @return Dataframe com informações processadas das licitações
#' 
#' @examples 
#' licitacoes_rs <- processa_licitacoes(2019, "covid")
processa_licitacoes_rs <- function(anos, filtro) {
  licitacoes_raw <- import_licitacoes(anos)
  
  licitacoes_rs <- licitacoes_raw %>%
    adapta_info_licitacoes(tipo_filtro = filtro)
  
  tipo_licitacao <- adapta_tipos_licitacoes()
  tipo_modalidade_licitacao <- adapta_tipos_modalidade_licitacoes()
  
  licitacoes_rs <- join_licitacao_e_tipo(licitacoes_rs, tipo_licitacao) %>%
    join_licitacao_e_tipo_modalidade(tipo_modalidade_licitacao) %>% 
    add_info_estado(sigla_estado = "RS", id_estado = "43")
  
  return(licitacoes_rs)
}