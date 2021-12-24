library(tidyverse)
library(magrittr)
library(here)
library(futile.logger)

#' Agrupa dados de municípios/administrações monitorados pelo Tá de pé
#'
#' No caso do governo Federal o municipio pode ser um órgão como uma Universidade pública.
#'
#' @param info_orgaos Dados de órgãos processados pelo aggregator_orgaos 
#' (transformer/processor/aggregator/aggregator_orgaos.R)
#' @return Dataframe com os municípios/administrações agregados e prontos para ir para o BD.
#' 
#' @examples 
#' municipios <- aggregator_municipios(info_orgaos = aggregator_orgaos(c(2020), "covid", c("PE", "RS")))
aggregator_municipios <- function(info_orgaos) {
  
  flog.info("#### Processando agregador de municípios...")
  
  info_municipios_monitorados <- info_orgaos %>% 
    dplyr::select(cd_municipio_ibge, nome_municipio, id_estado, sigla_estado) %>% 
    dplyr::mutate(slug_municipio = tolower(paste0(gsub(" ", "-", iconv(nome_municipio,from="UTF-8",to="ASCII//TRANSLIT")),
                                                  "-",
                                                  sigla_estado
    ))) %>%
    dplyr::mutate(nome_municipio = stringr::str_to_title(nome_municipio)) %>% 
    dplyr::distinct(cd_municipio_ibge, .keep_all = TRUE)
  
  return(info_municipios_monitorados)
}