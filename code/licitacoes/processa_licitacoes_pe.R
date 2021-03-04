source(here::here("code/utils/read_utils.R"))
source(here::here("code/filters/filter_merenda.R"))
source(here::here("code/filters/filter_covid.R"))

#' Importa dados de licitações do estado de Pernambuco
#' 
#' @return Dataframe com informações das licitações
#' 
#' @examples 
#' licitacoes <- read_licitacoes_pe()
import_licitacoes_pe <- function(ano) {
  
  message(paste0("Importando licitações de Pernambuco"))
  licitacoes <- read_licitacoes_pe()
  
  return(licitacoes)
}


#' Prepara dados para tabela de licitações filtradas
#'
#' @param licitacoes_df Dataframe de licitações para filtrar
#'
#' @return Dataframe com informações das licitações filtradas
#'   
#' @examples 
#' licitacoes <- processa_info_licitacoes(import_licitacoes(c(2019)))
#' 
#' Chave primária:
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade)
#' 
processa_info_licitacoes_pe <- function(licitacoes_df, tipo_filtro) {
  
  if (tipo_filtro == "merenda") {
    info_licitacoes <- licitacoes_df %>% 
      filter_licitacoes_merenda_pe()
    
  }
  # else if (tipo_filtro == "covid") {
  #   info_licitacoes <- licitacoes_df %>% 
  #     filter_licitacoes_covid()
  #   
  # } else {
  #   stop("Tipo de filtro não definido. É possível filtrar pelos tipos 'merenda' ou 'covid")
  # }
  
  
  info_licitacoes <- info_licitacoes %>% 
    janitor::clean_names() %>%
    dplyr::select(-razao_social, 
                  -numero_documento_ajustado,
                  -adjudicada,
                  -resultado_habilitacao,
                  -total_adjudicado_licitante) %>% 
    dplyr::distinct() %>% 
    dplyr::mutate(id_estado = "26",
                  vl_homologado = ifelse(total_adjudicado_licitacao == "" | is.na(total_adjudicado_licitacao), 
                                         valor_orcamento_estimativo, total_adjudicado_licitacao),
                  dt_adjudicacao = as.Date(data_publicacao_homologacao, format="%Y-%m-%d"),
                  vl_homologado = as.numeric(vl_homologado),
                  vl_licitacao = as.numeric(valor_orcamento_estimativo), assunto = "merenda") %>%
    dplyr::select(id_estado, cd_orgao = codigo_ug, nm_orgao = ug, nr_licitacao = codigo_pl, 
                  ano_licitacao = ano_processo, cd_tipo_modalidade = codigo_modalidade, 
                  descricao_objeto = objeto_conforme_edital, vl_estimado_licitacao = vl_licitacao, 
                  data_abertura = data_emissao_edital, data_homologacao = dt_adjudicacao,
                  data_adjudicacao = dt_adjudicacao, vl_homologado, assunto) %>% 
    unique()
  
  return(info_licitacoes)
}
