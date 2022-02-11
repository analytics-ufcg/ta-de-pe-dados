library(dplyr)
library(readr)
library(purrr)
library(magrittr)

source(here::here("transformer/utils/fetcher/fetcher_documentos_federais_relacionados.R"))
source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_compras_federal.R"))
source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_itens_compra_federal.R"))


# Lê o csv dos contratos do Governo Federal
contratos_processados_df <- read_contratos_processados()

itens_federais <- import_itens_compras_federais()


# Isola os contratos que tem alterações criando duas variáveis, uma contendo os contratos do Gov Federal e outra com os contratos restantes
contratos_filtrados <- contratos_processados_df %>% filter(tem_alteracoes == TRUE & id_estado == 99)
contratos_filtrados2 <- contratos_processados_df %>% filter(tem_alteracoes == TRUE & id_estado == 99)
contratos_processados_df <- contratos_processados_df %>% filter(tem_alteracoes == FALSE | tem_alteracoes == TRUE & id_estado != 99)

itens_federais <- itens_federais %>%
  select(codigo_empenho, descricao, valor_total)

contratos_filtrados <- contratos_filtrados %>%
  rename(codigo_empenho = codigo_contrato) %>%
  select(codigo_empenho, nm_orgao) %>%
  left_join(itens_federais, by = 'codigo_empenho')
  


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


empenhos_relacionados <- empenhos_relacionados %>%
  filter(Fase == "Empenho" & Espécie == "ANULAÇÃO" | Espécie == "REFORÇO") %>%
  rename(codigo_empenho = Documento) %>%
  left_join(itens_federais, by="codigo_empenho")
  
tabela_resultado <- empenhos_relacionados %>%
  rename(Documento = codigo_empenho,
         codigo_empenho = codigo_empenho_original) %>%
  left_join(contratos_filtrados, by="codigo_empenho")


line <- 1
for(i in tabela_resultado$descricao.x){
  if(!is.na(tabela_resultado[line, 8]) & startsWith(tabela_resultado[line, 8], "0")){
    i <- str_replace(i, "0+", "")
    tabela_resultado[line, 8] <- i
  }
  line <- line + 1
}


line <- 1
for(i in tabela_resultado$descricao.y){
  if(!is.na(tabela_resultado[line, 11]) & startsWith(tabela_resultado[line, 11], "0")){
    i <- str_replace(i, "0+", "")
    tabela_resultado[line, 11] <- i
  }
  line <- line + 1
}

line <- 1
cont <- 0

for(i in tabela_resultado$descricao.x){
  if(!is.na(tabela_resultado[line, 8]) &
     !is.na(tabela_resultado[line, 11]) & 
     gsub(" ", "",tabela_resultado[line, 8], fixed = TRUE) == gsub(" ", "",tabela_resultado[line, 11], fixed = TRUE)
     ){
    
    cont <- cont + 1
  } else {
    tabela_resultado[line,3] <- "0"
  }
  line <- line + 1
}

tabela_resultado <- tabela_resultado %>%
  filter(Documento != "0")


line <- 1
for(i in tabela_resultado$descricao.y){
  if(!is.na(tabela_resultado[line, 11]) & startsWith(tabela_resultado[line, 11], "0")){
    i <- str_replace(i, "0+", "")
    tabela_resultado[line, 11] <- i
  }
  line <- line + 1
}


tabela_resultado <- tabela_resultado %>%
  mutate(valor_total.x = ifelse(Espécie == "ANULAÇÃO", valor_total.x * -1, valor_total.x),
        valor_itens_relacionados = valor_total.y + valor_total.x) %>%
  group_by(codigo_empenho) %>%
  group_by(descricao.y) %>%
  mutate(valor_itens_relacionados = sum(valor_itens_relacionados)) %>%
  group_by(codigo_empenho) %>%
  distinct(descricao.y, .keep_all = TRUE) %>%
  filter(valor_itens_relacionados >= "0") %>%
  rename(codigo_contrato = codigo_empenho) %>%
  select(codigo_contrato, valor_itens_relacionados, descricao.y)



contratos_filtrados2 <- contratos_filtrados2 %>%
  left_join(tabela_resultado, by="codigo_contrato") %>%
  full_join(contratos_processados_df)

write_csv(contratos_filtrados2, here::here("./data/bd/info_contrato.csv"))

