source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/filters/filter_merenda.R"))
source(here::here("transformer/filters/filter_covid.R"))

#' Processa dados de licitações do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura das licitações
#' 
#' @return Dataframe com informações das licitações
#' 
#' @examples 
#' licitacoes <- import_licitacoes(2019)
import_licitacoes <- function(ano) {
  
  licitacoes <- purrr::pmap_dfr(list(ano),
                         ~ import_licitacoes_por_ano(..1)
  )
  
  return(licitacoes)
}

#' Importa dados de licitações em um ano específico para o estado do Rio Grande do Sul
#' @param ano Inteiro com o ano para recuperação das licitações
#' @return Dataframe com informações das licitações
#' @examples 
#' licitacoes <- import_licitacoes_por_ano(2019)
#' 
import_licitacoes_por_ano <- function(ano) {
  message(paste0("Importando licitações do ano ", ano))
  licitacoes <- read_licitacoes(ano)
  
  return(licitacoes)
}

#' Prepara dados para tabela de licitações filtradas
#'
#' @param licitacoes_df Dataframe de licitações para filtrar
#'
#' @return Dataframe com informações das licitações filtradas
#'   
#' @examples 
#' licitacoes <- adapta_info_licitacoes(import_licitacoes(c(2019)))
#' 
#' Chave primária:
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade)
#' 
adapta_info_licitacoes <- function(licitacoes_df, tipo_filtro) {
  
  if (tipo_filtro == "merenda") {
    info_licitacoes <- licitacoes_df %>% 
      filter_licitacoes_merenda()
    
  } else if (tipo_filtro == "covid") {
    info_licitacoes <- licitacoes_df %>% 
      filter_licitacoes_covid()
    
  } else {
    stop("Tipo de filtro não definido. É possível filtrar pelos tipos 'merenda' ou 'covid")
  }
  
  info_licitacoes <- info_licitacoes %>% 
    janitor::clean_names() %>% 
    dplyr::mutate(id_estado = "43",
           tp_fornecimento = ifelse(tp_fornecimento == "I" , "Integral", 
                                    ifelse(tp_fornecimento == "P", "Parcelado", NA)),
           vl_homologado = ifelse(vl_homologado == "", NA, vl_homologado),
           dt_adjudicacao = as.Date(dt_adjudicacao, format="%Y-%m-%d"),
           vl_homologado = as.numeric(vl_homologado),
           vl_licitacao = as.numeric(vl_licitacao)) %>%
    dplyr::select(id_estado, cd_orgao, nm_orgao, nr_licitacao, ano_licitacao, 
           cd_tipo_modalidade, permite_subcontratacao = bl_permite_subcontratacao,
           tp_fornecimento, descricao_objeto = ds_objeto, vl_estimado_licitacao = vl_licitacao, 
           data_abertura = dt_abertura, data_homologacao = dt_homologacao,
           data_adjudicacao = dt_adjudicacao, vl_homologado, tp_licitacao, assunto)
  
  return(info_licitacoes)
}
