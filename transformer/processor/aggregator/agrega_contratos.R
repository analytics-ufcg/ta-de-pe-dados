library(tidyverse)
source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/processor/estados/PE/contratos/processador_contratos_pe.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_contratos_rs.R"))

#' Agrupa todos os contratos dos estados disponíveis na plataforma Tá de pé
#' 
#' @param anos Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @return Dataframe os contratos agregados
#' 
#' @examples 
#' contratos <- agrega_contratos(c(2018, 2019, 2020))
agrega_contratos <- function(anos) {
  contratos_rs <- processa_contratos_rs(anos)
  
  contratos_pe <- processa_contratos_pe()
  
  todos_contratos <- contratos_rs %>% 
    bind_rows(contratos_pe) %>%
    select(id_estado, cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, 
           nr_contrato, ano_contrato, tp_instrumento_contrato,
           nm_orgao, nr_documento_contratado, dt_inicio_vigencia, vl_contrato, descricao_objeto_contrato)
  
  return(todos_contratos)
}