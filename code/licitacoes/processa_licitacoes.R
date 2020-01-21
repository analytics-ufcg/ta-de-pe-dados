source(here::here("code/utils/utils.R"))

#' Processa dados de licitações do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura das licitações
#' 
#' @return Dataframe com informações das licitações
#' 
#' @examples 
#' licitacoes <- import_licitacoes(2019)
#' 
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

#' Carrega licitações de merenda a partir de um filtro aplicado a todas as licitações
#'
#' @param anos Vector de inteiros com anos para captura das licitações
#'
#' @return Dataframe com informações das licitações de merenda
#'   
#' @examples 
#' licitacoes_merenda <- filter_licitacoes_merenda(2019)
#' 
filter_licitacoes_merenda <- function(licitacoes_df) {
  
  licitacoes_cpp <- licitacoes_df %>% 
    dplyr::filter(CD_TIPO_MODALIDADE == "CPP",
           CD_TIPO_FASE_ATUAL == "ADH")
  
  licitacoes_palavra_chave <- licitacoes_df %>% 
    dplyr::filter(grepl("merenda", 
                 tolower(DS_OBJETO)), 
           CD_TIPO_FASE_ATUAL == "ADH")
  
  licitacoes_merenda <- dplyr::bind_rows(licitacoes_cpp, 
                                         licitacoes_palavra_chave) %>% 
    dplyr::distinct()

  return(licitacoes_merenda)
}

#' Prepara dados para tabela de licitações de merenda
#'
#' @param anos Vector de inteiros com anos para captura das licitações
#'
#' @return Dataframe com informações das licitações de merenda
#'   
#' @examples 
#' licitacoes_merenda <- processa_info_licitacoes(2019)
#' 
#' Chave primária:
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade)
#' 
processa_info_licitacoes <- function(licitacoes_df) {
  
  info_licitacoes <- licitacoes_df %>% 
    filter_licitacoes_merenda() %>% 
    janitor::clean_names() %>% 
    dplyr::mutate(id_estado = "43",
           tp_fornecimento = ifelse(tp_fornecimento == "I" , "Integral", 
                                    ifelse(tp_fornecimento == "P", "Parcelado", NA)),
           vl_homologado = ifelse(vl_homologado == "", NA, vl_homologado),
           dt_adjudicacao = as.Date(dt_adjudicacao, format="%Y-%m-%d"),
           vl_homologado = as.numeric(vl_homologado),
           vl_licitacao = as.numeric(vl_licitacao)) %>%
    
    dplyr::select(id_estado, id_orgao = cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, 
           permite_subcontratacao = bl_permite_subcontratacao, tp_fornecimento, 
           descricao_objeto = ds_objeto, vl_estimado_licitacao = vl_licitacao, 
           data_adjudicacao = dt_adjudicacao, vl_homologado, tp_licitacao)
  
  return(info_licitacoes)
}
