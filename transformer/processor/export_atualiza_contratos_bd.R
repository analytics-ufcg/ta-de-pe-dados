library(dplyr)
library(readr)
library(purrr)
library(magrittr)

source(here::here("transformer/utils/fetcher/fetcher_documentos_federais_relacionados.R"))
source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_compras_federal.R"))

# Lê o csv dos contratos do Governo Federal
contratos_processados_df <- read_contratos_processados()
# Importa os empenhos do Governo Federal e isola apenas o valor e o código dos empenhos
empenhos_federais <- import_empenhos_federal() %>% select(valor_original, codigo)



# Isola os contratos que tem alterações criando duas variáveis, uma contendo os contratos do Gov Federal e outra com os contratos restantes
contratos_filtrados <- contratos_processados_df %>% filter(tem_alteracoes == TRUE & id_estado == 99)
contratos_processados_df <- contratos_processados_df %>% filter(tem_alteracoes == FALSE | tem_alteracoes == TRUE & id_estado != 99)

empenhos_relacionados <- data.frame(Data=character(),
                                    Fase=character(), 
                                    Documento=character(), 
                                    Espécie=character(), 
                                    codigo_empenho_original=character(), 
                                    stringsAsFactors=FALSE) 


contratos_filtrados$grupo <- 1:13085 %% 20 + 1

agrupamento <- split(contratos_filtrados, contratos_filtrados$grupo)

group <- 1

# Atribui a variável 'empenhos_relacionados' TODOS os empenhos relacionados baixados
# referentes aos empenhos passados pelos contratos do Governo Federal que tem alteração.
for(grupo in agrupamento){
  tryCatch({
    data_frame_relacionados <- grupo$codigo_contrato %>% map_df(fetch_documentos_relacionados_federais)
    write_csv(data_frame_relacionados, here::here(str_glue("data/dados_federais/empenhos_documentos_relacionados_checkpoint{group}.csv")))
    empenhos_relacionados <<- empenhos_relacionados %>% full_join(data_frame_relacionados)
    }, error = function(e) {
    flog.info("Não foi possível realizar o download dos dados!")
    flog.error(e)
  })
  group <<- group + 1
}

# Torna os valores das anulações negativas e soma os valores de empenhos relacionados que estejam
# relacionados ao mesmo empenho original.
empenhos_relacionados <- empenhos_relacionados %>% filter(Fase == "Empenho") %>%
  rename(codigo = Documento) %>%
  select(-X5) %>%
  left_join(empenhos_federais, by="codigo") %>% 
  mutate(valor_original = ifelse(Espécie == "ANULAÇÃO", valor_original * -1, valor_original),
         ) %>%
  group_by(codigo_empenho_original) %>%
  mutate(alteracoes = sum(valor_original)) %>%
  distinct(codigo_empenho_original, .keep_all = TRUE)

# Atualiza na tabela empenhos_relacionados o valor dos contratos somando as alterações com o valor original
empenhos_relacionados <- empenhos_federais %>%
  select(codigo, valor_original) %>%
  rename(codigo_empenho_original = codigo,
         valor_empenho_original = valor_original) %>%
  right_join(empenhos_relacionados, by="codigo_empenho_original") %>%
  mutate(valor_final = valor_empenho_original + alteracoes) %>%
  select(codigo_empenho_original, valor_empenho_original, alteracoes, valor_final)

write_csv(empenhos_relacionados, here::here("data/dados_federais/empenhos_documentos_relacionados.csv"))

# Leva o valor atualizado dos empenhos_relacionados para a tabela de contratos_filtrados e depois devolve
# essa amostra atualizada para a tabela de onde a amostra havia sido retirada.
contratos_filtrados <- contratos_filtrados %>%
  right_join(empenhos_relacionados %>% 
               rename(codigo_contrato = codigo_empenho_original) %>%
               select(codigo_contrato, valor_final), by="codigo_contrato") %>%
  mutate(vl_contrato = valor_final) %>%
  select(-valor_final) %>%
  full_join(contratos_processados_df)


write_csv(contratos_filtrados, here::here("./data/bd/info_contrato.csv"))

