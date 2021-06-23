source(here::here("transformer/utils/read_utils.R"))

#' Processa dados dos eventos das licitações para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos eventos das licitações
#' 
#' @return Dataframe com informações dos eventos das licitações
#' 
#' @examples 
#' eventos_licitacoes <- import_eventos_licitacoes(2019)
import_eventos_licitacoes <- function(ano) {
  
  eventos_licitacoes <- purrr::pmap_dfr(list(ano),
                                ~ import_eventos_licitacoes_por_ano(..1)
  )
  
  return(eventos_licitacoes)
}

#' Importa dados dos eventos das licitações em um ano específico
#' @param ano Inteiro com o ano para recuperação dos eventos das licitações
#' @return Dataframe com informações dos eventos das licitações
#' @examples 
#' eventos_licitacoes <- import_eventos_licitacoes_por_ano(2019)
#' 
import_eventos_licitacoes_por_ano <- function(ano) {
  message(paste0("Importando eventos das licitações do ano ", ano))
  eventos_licitacoes <- read_eventos_licitacoes(ano)
  
  return(eventos_licitacoes)
}

#' Filtra dataframe de eventos de licitações para retornar apenas as licitações encerradas
#' de forma "natural" (não por falta de propostas ou por suspensão judicial).
#' @param eventos_df Dataframe com eventos das licitações
#' @return Dataframe com informações dos eventos das licitações filtrando apenas as encerradas
#' @examples 
#' eventos_licitacoes <- import_eventos_licitacoes_por_ano(2019)
#' 
filtra_licitacoes_encerradas <- function(eventos_df) {
  eventos_filtrados <- eventos_df %>% 
    janitor::clean_names() %>%
    group_by(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade) %>% 
    summarise(cd_tipo_evento = paste(cd_tipo_evento, collapse = ";"),
              data_evento = first(dt_evento)) %>% 
    ungroup() %>% 
    filter(str_detect(cd_tipo_evento, "ENC"),
           !str_detect(cd_tipo_evento, "EFC|EFH|EFI|SDJ|SUM|SUO"))
  
  # ENC	Encerramento
  # EFC	Encerramento por falta de propostas classificadas
  # EFH	Encerramento por falta de licitantes habilitados
  # EFI	Encerramento por falta de interessados
  # SDJ	Suspensão por determinação judicial
  # SUM	Suspensão por medida cautelar
  # SUO	Suspensão de ofício
    
  return(eventos_filtrados)
}
