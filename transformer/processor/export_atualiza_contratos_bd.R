library(dplyr)
library(readr)
library(purrr)
library(magrittr)

source(here::here("transformer/utils/fetcher/export_documentos_federais_relacionados.R"))
source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_compras_federal.R"))

contratos_processados_df <- read_contratos_processados()
empenhos_federais <- import_empenhos_federal() %>% select(codigo, valor_original)

filtra_contratos_tem_alteracoes <- function(contratos_processados_df){
  contratos_filtrados <- contratos_processados_df %>% filter(tem_alteracoes == TRUE & id_estado == 99)
  
  return(contratos_filtrados)
}

empenhos_relacionados <- data.frame(Data=character(),
                                    Fase=character(), 
                                    Documento=character(), 
                                    Espécie=character(), 
                                    stringsAsFactors=FALSE) 

gera_df_documentos_relacionados <- function(documentos_relacionados){
  
  empenhos_relacionados <<- full_join(empenhos_relacionados, documentos_relacionados, copy=TRUE)
  
  return(empenhos_relacionados)
}

contratos_filtrados <- filtra_contratos_tem_alteracoes(contratos_processados_df)

contratos_filtrados$codigo_contrato %>% 
  map(fetch_documentos_relacionados_federais) %>% 
  map(gera_df_documentos_relacionados)

write_csv2(empenhos_relacionados, "./data/empenhos.csv")
