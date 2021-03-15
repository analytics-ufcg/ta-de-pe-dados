source(here::here("transformer/adapter/estados/RS/contratos/adaptador_tipos_alteracoes_contratos_rs.R"))

#' Processa dados dos tipos de alterações dos contratos do estado do Rio Grande do Sul 
#' para um conjunto de filtros
#' 
#' @param anos Vector de inteiros com anos para captura dos tipos de alterações dos contratos
#' 
#' @return Dataframe com informações processadas com os tipos de alterações dos contratos
#' 
#' @examples 
#' tipo_operacao_alteracao <- processa_tipos_alteracoes_contratos_rs(anos)
processa_tipos_alteracoes_contratos_rs <- function(anos) {
  tipo_operacao_alteracao <- adapta_tipos_alteracao_contrato()
  
  return(tipo_operacao_alteracao)
}