source(here::here("transformer/adapter/estados/PE/orgaos/adaptador_orgaos_pe.R"))
source(here::here("transformer/adapter/estados/PE/licitacoes/adaptador_licitacoes_pe.R"))

#' Processa dados dos órgãos do estado de Pernambuco
#' 
#' @return Dataframe com informações processadas dos órgãos
#' 
#' @examples 
#' info_orgaos_pe <- processa_orgaos_pe()
processa_orgaos_pe <- function() {
  licitacoes_pe_orgaos <- import_licitacoes_pe() %>%
    adapta_info_licitacoes_pe(tipo_filtro = filtro) %>%
    add_info_estado(sigla_estado = "PE", id_estado = "26") %>% 
    dplyr::distinct(cd_orgao, nm_orgao, sigla_estado, id_estado)

  info_orgaos_pe <- import_orgaos_municipais_pe() %>%
    adapta_info_orgaos_pe(import_orgaos_estaduais_pe(), import_municipios_pe()) %>%
    select(-sigla_estado) %>% 
    add_info_estado(sigla_estado = "PE", id_estado = "26") %>% 
    dplyr::bind_rows(licitacoes_pe_orgaos) %>% 
    dplyr::distinct(cd_orgao, .keep_all = TRUE) %>% 
    dplyr::mutate(nome_municipio = dplyr::if_else(is.na(cd_municipio_ibge) & is.na(nome_municipio),
                                                  "Outros órgãos em Pernambuco",
                                                  nome_municipio)) %>% 
    dplyr::mutate(cd_municipio_ibge = dplyr::if_else(is.na(cd_municipio_ibge),
                                                     "0",
                                                     cd_municipio_ibge))
  
  return(info_orgaos_pe)
}
