library(tidyverse)
library(magrittr)
library(here)
library(futile.logger)

source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/constants.R"))

source(here::here("transformer/processor/estados/RS/orgaos/processador_orgaos_rs.R"))
source(here::here("transformer/processor/estados/PE/orgaos/processador_orgaos_pe.R"))

#' Agrupa dados de órgãos monitorados pelo Tá de pé
#'
#' @param anos Array com os anos para processamento.
#' @param filtro Filtro usado para filtrar os órgãos.
#' @param administracao Array com a lista de estados/administrações para processar.
#' @return Dataframe com os órgãos agregados e prontos para ir para o BD.
#' 
#' @examples 
#' orgaos_agregados <- aggregator_orgaos(c(2020), "covid", c("PE", "RS"))
aggregator_orgaos <- function(anos, filtro, administracao = c("PE", "RS")) {
  
  flog.info("#### Processando agregador de órgãos...")
  
  if ("RS" %in% administracao) {
    orgaos_rs <- tryCatch({
      flog.info("processando órgãos do RS...")
      processa_orgaos_rs(anos, filtro)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de órgãos do RS")
      flog.error(e)
      return(tibble())
    })
  } else {
    orgaos_rs <- tibble()
  }
  
  if ("PE" %in% administracao) {
    orgaos_pe <- tryCatch({
      flog.info("processando órgãos do PE...")
      processa_orgaos_pe()
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de órgãos do PE")
      flog.error(e)
      return(tibble())
    })
  } else {
    orgaos_pe <- tibble()
  }
  
  info_orgaos <- bind_rows(orgaos_rs,
                           orgaos_pe) %>%
    generate_hash_id(c("cd_orgao", "id_estado"),
                     O_ID) %>%
    dplyr::mutate(cd_municipio_ibge = dplyr::if_else(stringr::str_detect(nome_municipio, "ESTADO"), 
                                                     id_estado,
                                                     cd_municipio_ibge)) %>% 
    dplyr::select(id_orgao, dplyr::everything())
  
  return(info_orgaos)
}