source(here::here("code/utils/read_utils.R"))


#' Importa dados dos orgãos do estado do Rio Grande do Sul
#' @return Dataframe com informações das orgãos
#' @examples 
#' orgaos <- import_orgaos()
#' 
import_orgaos <- function() {
  message("Importando orgaos")
  orgaos <- read_orgaos()
  
  return(orgaos)
}

#' Cria dataframe com informações dos orgãos participantes de licitações
#' 
#' @examples 
#' orgaos <- processa_info_orgaos()
#' 
processa_info_orgaos <- function(orgaos_df) {
  
  info_orgaos <- orgaos_df %>%
    janitor::clean_names() %>% 
    dplyr::select(id_orgao = cd_orgao, nm_orgao = nome_orgao, sigla_orgao, 
                  esfera, home_page, nome_municipio, cd_municipio_ibge)
  
  return(info_orgaos)
}
