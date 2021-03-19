source(here::here("transformer/utils/read_utils.R"))


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
#' orgaos <- adapta_info_orgaos()
#' 
adapta_info_orgaos <- function(orgaos_df, licitacoes) {
  
  orgaos_licitacao <- licitacoes %>%
    dplyr::distinct(cd_orgao, nm_orgao)
  
  info_orgaos <- orgaos_df %>%
    janitor::clean_names() %>% 
    dplyr::select(cd_orgao, nm_orgao = nome_orgao, sigla_orgao, 
                  esfera, home_page, nome_municipio, cd_municipio_ibge) %>%
    dplyr::mutate(cd_orgao = as.character(cd_orgao), cd_municipio_ibge = as.character(cd_municipio_ibge)) %>%
    dplyr::bind_rows(orgaos_licitacao %>%
                       dplyr::mutate(esfera = "ESTADUAL")) %>%
    dplyr::distinct(cd_orgao, .keep_all = TRUE) %>%
    dplyr::mutate(nome_entidade = nome_municipio) %>%
    dplyr::mutate(nome_municipio = dplyr::if_else(esfera == "ESTADUAL",
                                                  "ESTADO DO RIO GRANDE DO SUL",
                                                  nome_municipio)) %>%
    # dplyr::mutate(sigla_estado = "RS", id_estado = "43") %>%
    # generate_hash_id(c("id_orgao", "sigla_estado"),
    #                  O_ID) %>%
    # dplyr::select(id_orgao, dplyr::everything()) %>% 
    unique()
  
  return(info_orgaos)
}
