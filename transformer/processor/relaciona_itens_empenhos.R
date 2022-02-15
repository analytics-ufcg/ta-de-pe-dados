library(dplyr)
library(readr)
library(purrr)
library(magrittr)

source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_itens_compra_federal.R"))


itens_federais <- import_itens_compras_federais()

empenhos_relacionados <- data.frame(Data=character(),
                                    Fase=character(), 
                                    Documento=character(), 
                                    Espécie=character(), 
                                    X5 = character(),
                                    codigo_empenho_original=character(), 
                                    stringsAsFactors=FALSE) 

for(i in c(1:20)){
  empenhos_relacionados <<- empenhos_relacionados %>%
    full_join(read_csv(here::here(str_glue("data/dados_federais/empenhos_documentos_relacionados_checkpoint{i}.csv"))))
}


tabela_resultado <- empenhos_relacionados %>%
  filter(Fase == "Empenho" & Espécie != "ORIGINAL") %>%
  rename(codigo_empenho = Documento) %>%
  left_join(itens_federais, by="codigo_empenho") %>%
  rename(Documento = codigo_empenho,
         codigo_empenho = codigo_empenho_original)

line <- 1
for(i in tabela_resultado$descricao){
  if(!is.na(tabela_resultado[line, 8]) & startsWith(tabela_resultado[line, 8], "0")){
    i <- str_replace(i, "0+", "")
    tabela_resultado[line, 8] <- i
  }
  line <- line + 1
  tabela_resultado[line, 8] <- gsub(" ", "",tabela_resultado[line, 8], fixed = TRUE)
}


valores_itens_empenhos_relacionados <- tabela_resultado %>%
  mutate(valor_total = ifelse(Espécie == "ANULAÇÃO", valor_total * -1, valor_total)) %>%
  group_by(codigo_empenho) %>% 
  group_by(descricao) %>%
  mutate(valor_itens_empenhos_relacionados = sum(valor_total)) %>%
  group_by(codigo_empenho) %>%
  distinct(descricao, .keep_all = TRUE) %>%
  filter(valor_itens_empenhos_relacionados >= "0") %>%
  select(codigo_empenho, descricao, valor_itens_empenhos_relacionados)


tabela_resultado <- itens_federais %>%
  left_join(teste, by= c("codigo_empenho", "descricao")) %>%
  mutate(contem_calculo_itens_relacionados = ifelse(!is.na(valor_itens_empenhos_relacionados), TRUE, FALSE))

write_csv(tabela_resultado, here::here("./data/bd/info_item_contrato.csv"))

