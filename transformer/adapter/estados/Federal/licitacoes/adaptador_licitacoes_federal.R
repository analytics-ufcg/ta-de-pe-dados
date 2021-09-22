source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/filters/filter_merenda.R"))
source(here::here("transformer/filters/filter_covid.R"))
source(here::here("transformer/utils/read/read_empenhos_federais.R"))

#' Importa dados de licitações Federais
#' 
#' @return Dataframe com informações das licitações federais
#' 
#' @examples 
#' licitacoes <- import_licitacoes_federal()
import_licitacoes_federal <- function() {
  
  message(paste0("Importando licitações Federais"))
  licitacoes <- read_licitacoes_federal()
  
  return(licitacoes)
}


#' Prepara dados para tabela de licitações federais filtradas
#'
#' @param licitacoes_df Dataframe de licitações para filtrar
#' 
#' @param tipo_filtro Tipo de filtro para aplicar as licitações.
#'
#' @return Dataframe com informações das licitações do governo federal filtradas 
#'   
#' @examples 
#' licitacoes <- adapta_info_licitacoes_federal(import_licitacoes_federal(), tipo_filtro)
#' 
#' Chave primária:
#' (cd_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade)
#' 
adapta_info_licitacoes_federal <- function(licitacoes_df, tipo_filtro) {
  
  if (tipo_filtro == "merenda") {
    # TODO: aplicar filtro de merenda
    info_licitacoes <- licitacoes_df
  } else if (tipo_filtro == "covid") {
    # TODO: aplicar filtro de covid
    info_licitacoes <- licitacoes_df %>% 
      filter_licitacoes_federais_covid()
  } else {
    stop("Tipo de filtro não definido. É possível filtrar pelos tipos 'merenda' ou 'covid")
  }
  
  ## Filtro para remover órgãos fora do contexto do Governo Federal
  info_licitacoes_filtrados <- info_licitacoes %>% 
    filter(as.numeric(codigo_orgao_superior) %% 1000 == 0, 
           as.numeric(codigo_orgao_superior) > 2e4, as.numeric(codigo_orgao_superior) < 9e4)
  
  flog.info(str_glue("{info_licitacoes %>% nrow() - info_licitacoes_filtrados %>% nrow()} licitação(ões) foi/foram removida(s)",
                     " pois pertence(m) a órgãos que não são de interesse de monitoramento."))
  
  info_licitacoes <- info_licitacoes_filtrados %>% 
    janitor::clean_names() %>%
    dplyr::mutate(id_estado = "99",
                  ano_data_abertura = lubridate::year(data_abertura),
                  ano_licitacao = if_else(is.na(ano_data_abertura),
                                      substr(numero_licitacao, nchar(numero_licitacao) - 3, nchar(numero_licitacao)),
                                      as.character(ano_data_abertura)),
                  ano_licitacao = as.integer(ano_licitacao),
                  permite_subcontratacao = NA_character_,
                  tp_fornecimento = NA_character_,
                  data_adjudicacao = as.Date(NA_character_),
                  vl_homologado = NA_real_,
                  tp_licitacao = NA_character_,
                  assunto = NA_character_,
                  tipo_licitacao = NA_character_) %>%
    dplyr::select(id_estado, 
                  cd_orgao = codigo_ug, 
                  nm_orgao = nome_ug, 
                  nr_licitacao = numero_licitacao, 
                  ano_licitacao, 
                  cd_tipo_modalidade = codigo_modalidade_compra,
                  permite_subcontratacao, 
                  tp_fornecimento,
                  descricao_objeto = objeto, 
                  vl_estimado_licitacao = valor_licitacao, 
                  data_abertura, 
                  data_homologacao = data_resultado_compra,
                  data_adjudicacao, 
                  vl_homologado, 
                  tp_licitacao, 
                  assunto, 
                  tipo_licitacao, 
                  tipo_modalidade_licitacao = modalidade_compra) %>% 
    dplyr::distinct()
  
  return(info_licitacoes)
}
