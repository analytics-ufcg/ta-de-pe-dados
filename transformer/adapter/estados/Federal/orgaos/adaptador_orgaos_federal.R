source(here::here("transformer/utils/read_utils.R"))

#' Importa dados dos órgãos federais
#' @return Dataframe com informações dos órgãos federais
#' @examples 
#' orgaos <- import_orgaos_federal()
#' 
import_orgaos_federal <- function() {
  message("Importando órgãos do governo federal")
  orgaos <- read_licitacoes_federal() ## os órgãos federais são extraídos das licitações
  
  return(orgaos)
}

#' Cria dataframe com informações dos orgãos federais
#' 
#' @examples 
#' orgaos <- adapta_info_orgaos_federal()
#' 
adapta_info_orgaos_federal <- function(orgaos_df) {
  
  info_orgaos <- orgaos_df %>% 
    mutate(esfera = "FEDERAL",
           home_page = NA_character_) %>% 
    select(cd_orgao = codigo_ug,
           nm_orgao = nome_ug,
           sigla_orgao = nome_ug,
           esfera,
           home_page,
           nome_municipio = nome_orgao,
           cd_municipio_ibge = codigo_orgao,
           nome_entidade = nome_orgao,
           ) %>% 
      distinct(cd_orgao, .keep_all = TRUE)
  
  return(info_orgaos)
}

#' Cria dataframe com informações dos orgãos federais a partir da base de empenhos
#' 
#' @examples 
#' orgaos <- adapta_info_orgaos_federal()
#' 
adapta_info_orgaos_federal_empenhos <- function(empenhos_df) {
  
  info_orgaos <- empenhos_df %>% 
    mutate(esfera = "FEDERAL",
           home_page = NA_character_) %>% 
    select(cd_orgao = codigo_unidade_gestora,
           nm_orgao = unidade_gestora,
           sigla_orgao = unidade_gestora,
           esfera,
           home_page,
           nome_municipio = orgao,
           cd_municipio_ibge = codigo_orgao,
           nome_entidade = orgao,
    ) %>% 
    distinct(cd_orgao, .keep_all = TRUE)
  
  return(info_orgaos)
}
