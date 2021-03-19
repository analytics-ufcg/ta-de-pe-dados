source(here::here("transformer/adapter/estados/RS/licitacoes/adaptador_documentos_licitacoes_rs.R"))
source(here::here("transformer/adapter/estados/RS/licitacoes/adaptador_tipos_documentos_licitacoes_rs.R"))

#' Processa dados dos documentos das licitações do estado do Rio Grande do Sul 
#' para um conjunto de filtros
#' 
#' @param anos Vector de inteiros com anos para captura dos documentos
#' 
#' @return Dataframe com informações processadas dos documentos
#' 
#' @examples 
#' documento_licitacao_rs <- processa_documentos_licitacoes_rs(2019)
processa_documentos_licitacoes_rs <- function(anos) {
  tipos_documento_licitacao <- adapta_tipos_documento_licitacoes()
  
  documento_licitacao_rs <- import_documentos_licitacoes(anos) %>%
    adapta_info_documentos_licitacoes() %>% 
    add_info_estado(sigla_estado = "RS", id_estado = "43")
  
  return(documento_licitacao_rs)
}