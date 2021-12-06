library(dplyr)
library(readr)
library(purrr)
library(magrittr)

source(here::here("transformer/utils/fetcher/export_documentos_federais_relacionados.R"))
source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_compras_federal.R"))

docs_rel_teste <- read_csv2("data/documentos-relacionados(14).csv")

export_contratos_atualizados <-function(){
  contratos_processados_df <- read_contratos_processados()
  empenhos_federais <- import_empenhos_federal() %>% select(codigo, valor_original)
  
  filtra_contratos_tem_alteracoes <- function(contratos_processados_df){
    contratos_filtrados <- contratos_processados_df %>% filter(tem_alteracoes == TRUE & id_estado == 99) %>% head(n=500)
    
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
  
  fetch_documentos_relacionados <- contratos_filtrados$codigo_contrato %>% 
    map(fetch_documentos_relacionados_federais)
  
    fetch_documentos_relacionados %>% map(gera_df_documentos_relacionados)
    
  
  
  empenhos_relacionados <- empenhos_relacionados %>% filter(Fase == "Empenho") %>%
    rename(codigo = Documento) %>%
    select(-X5) %>%
    left_join(empenhos_federais, by="codigo") %>% 
    mutate(valor_original = ifelse(Espécie == "ANULAÇÃO", valor_original * -1, valor_original))

  

  
  return(contratos_atualizados)
}

