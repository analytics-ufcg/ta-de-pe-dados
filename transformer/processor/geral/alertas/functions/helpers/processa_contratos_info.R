library(tidyverse)
library(magrittr)
source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/processor/aggregator/agrega_contratos.R"))

#' Agrupa todos os contratos e compras realizadas em um período de tempo. 
#' Os contratos considerados independem do assunto (filtro), já as compras consideradas envolvem apenas contratos do assunto. 
#' 
#' @param anos Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @param estados Array com os estados para considerar nos contratos
#' @return Dataframe com alertas para a diferença de daras
#' 
#' @examples 
#' contratos_merge <- processa_contratos_info(c(2018, 2019, 2020), c("RS", "PE", "BR"))
processa_contratos_info <- function(anos, estados = c("RS", "PE", "BR")) {
  contratos_processados <- read_contratos_processados() %>% 
    mutate(id_orgao = as.character(id_orgao)) %>% 
    select(id_contrato, id_estado, id_orgao, cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, 
           nr_contrato, ano_contrato, tp_instrumento_contrato,
           nm_orgao, nr_documento_contratado, dt_inicio_vigencia, vl_contrato, 
           descricao_objeto_contrato)

  todos_contratos <- agrega_contratos(anos, estados)
  
  contratos_merge <- contratos_processados %>% 
    bind_rows(todos_contratos) %>% 
    distinct(id_estado, cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, 
             nr_contrato, ano_contrato, tp_instrumento_contrato, .keep_all = T)
  
  return(contratos_merge)
}
