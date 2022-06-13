library(dplyr)
library(readr)
library(purrr)
library(magrittr)
library(futile.logger)

source(here::here("transformer/utils/fetcher/fetcher_documentos_federais_relacionados.R"))
source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_compras_federal.R"))

# Lê o csv dos contratos do Governo Federal
contratos_processados <- read_contratos_processados()
# Importa os empenhos do Governo Federal e isola apenas o valor e o código dos empenhos
empenhos_federais <- import_empenhos_federal() %>% select(valor_original, codigo)

# Isola os contratos que tem alterações criando duas variáveis,
# uma contendo os contratos do Gov Federal e outra com os contratos restantes
contratos_filtrados <-
  contratos_processados %>% filter(tem_alteracoes == TRUE &
                                     id_estado == 99)
contratos_processados_df <-
  contratos_processados %>% filter(!(id_contrato %in% (
    contratos_filtrados %>% pull(id_contrato)
  )))

empenhos_relacionados <- data.frame(Data=character(),
                                    Fase=character(), 
                                    Documento=character(), 
                                    Espécie=character(), 
                                    codigo_empenho_original=character(), 
                                    stringsAsFactors=FALSE) 

numero_de_linhas <- count(contratos_filtrados)
contratos_filtrados$grupo <- 1:numero_de_linhas$n %% 20 + 1

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

write_csv(empenhos_relacionados, here::here("data/dados_federais/empenhos_documentos_relacionados.csv"))

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
  mutate(valor_final = ifelse(is.na(alteracoes), valor_empenho_original, valor_empenho_original + alteracoes)) %>%
  select(codigo_empenho_original, valor_empenho_original, alteracoes, valor_final)

# Leva o valor atualizado dos empenhos_relacionados para a tabela de contratos_filtrados e depois devolve
# essa amostra atualizada para a tabela de onde a amostra havia sido retirada.
contratos_atualizados <- contratos_filtrados %>%
  left_join(empenhos_relacionados %>% 
               rename(codigo_contrato = codigo_empenho_original) %>%
               select(codigo_contrato, valor_final), by="codigo_contrato") %>%
  mutate(vl_contrato = ifelse(is.na(valor_final), vl_contrato, valor_final)) %>%
  mutate(language = 'portuguese') %>%
  select(-valor_final, -grupo) %>%
  bind_rows(contratos_processados_df) %>% 
  select(id_contrato, id_estado, id_orgao, id_licitacao, codigo_contrato, nr_contrato,
         ano_contrato, cd_orgao, nm_orgao, nr_processo, ano_processo, tp_documento_contratado,
         nr_documento_contratado, dt_inicio_vigencia, dt_final_vigencia, vl_contrato,
         descricao_objeto_contrato, nr_licitacao, sigla_estado, tp_instrumento_contrato, contrato_possui_garantia,
         vigencia_original_do_contrato, justificativa_contratacao, obs_contrato, tipo_instrumento_contrato, 
         ano_licitacao, cd_tipo_modalidade, tem_alteracoes, language)

if (nrow(contratos_processados) != nrow(contratos_atualizados)) {
  flog.error("Erro na atualização dos valores dos contratos: número de contratos inválido")
  stop("Erro na atualização dos valores dos contratos: número de contratos inválido")
}

flog.info("#### escrevendo dados...")
write_csv(contratos_atualizados, here::here("./data/bd/info_contrato.csv"))
flog.info("#### Contratos atualizados!")