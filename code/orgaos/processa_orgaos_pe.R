source(here::here("code/utils/read_utils.R"))


#' Importa dados dos orgãos estaduais do estado de Pernambuco
#' @return Dataframe com informações das orgãos
#' @examples 
#' orgaos <- import_orgaos_estaduais_pe()
#' 
import_orgaos_estaduais_pe <- function() {
  message("Importando orgãos estaduais")
  orgaos_estaduais <- read_orgaos_estaduais_pe()
  
  return(orgaos_estaduais)
}


#' Importa dados dos orgãos municipais do estado de Pernambuco
#' @return Dataframe com informações das orgãos
#' @examples 
#' orgaos <- import_orgaos_municipais_pe()
#' 
import_orgaos_municipais_pe <- function() {
  message("Importando orgãos municipais")
  orgaos_municipais <- read_orgaos_municipais_pe()
    
  return(orgaos_municipais)
}

#' Importa dados dos municípios do estado de Pernambuco
#' @return Dataframe com informações das municípios
#' @examples 
#' orgaos <- import_municipios_pe()
#' 
import_municipios_pe <- function() {
  message("Importando municípios")
  municipios <- read_municipios_pe()
  
  return(municipios)
}

#' Cria dataframe com informações dos orgãos participantes de licitações
#' 
#' @examples 
#' orgaos <- processa_info_orgaos_pe()
#' 
processa_info_orgaos_pe <- function(orgaos_municipais, orgaos_estaduais, municipios) {
  
  info_municipios <- municipios %>%
    janitor::clean_names() %>% 
    dplyr::mutate(nome_municipio = nome, cd_municipio_ibge = codigo_ibge,
                  sigla_estado = cunifed) %>% 
    dplyr::select(codigo, nome_municipio, cd_municipio_ibge, sigla_estado)
  
  info_orgaos_municipais <- orgaos_municipais %>%
    janitor::clean_names() %>% 
    dplyr::mutate(cd_orgao = id_unidade_gestora, nm_orgao = nome_unidade_gestora,
                  sigla_orgao = NA, esfera = "MUNICIPAL", home_page = NA) %>% 
    dplyr::select(cd_orgao, nm_orgao, sigla_orgao, esfera, home_page, 
                  codigo = codigo_municipio_unidade_gestora) %>% 
    dplyr::left_join(info_municipios)
  
  info_orgaos_estaduais <- orgaos_estaduais %>%
    janitor::clean_names() %>% 
    dplyr::mutate(cd_orgao = id_unidadegestora, nm_orgao = nome_unidade_gestora,
                  sigla_orgao = NA, esfera = "ESTADUAL", home_page = NA,
                  nome_municipio = "ESTADO DE PERNAMBUCO", nome_entidade = NA) %>% 
    dplyr::select(cd_orgao, nm_orgao, sigla_orgao, esfera, home_page, nome_municipio,
                  nome_entidade)
  
  info_orgaos <- info_orgaos_municipais %>% 
    dplyr::bind_rows(info_orgaos_estaduais) %>%
    dplyr::select(-codigo)
  
  return(info_orgaos)
}
