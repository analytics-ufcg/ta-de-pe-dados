library(dplyr)
library(readr)
library(purrr)
library(magrittr)

source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_itens_compra_federal.R"))

itens_federais <- import_itens_compras_federais()

# TODO Organizar função de leitura do arquivo do Governo Federal
# Ler do arquivo total ao invés de ler dos checkpoints
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
# TODO FIM

itens_empenhos_relacionados <- empenhos_relacionados %>%
  filter(Fase == "Empenho" & Espécie != "ORIGINAL") %>%
  rename(codigo_empenho = Documento) %>%
  left_join(itens_federais, by="codigo_empenho") %>%
  rename(Documento = codigo_empenho,
         codigo_empenho = codigo_empenho_original) %>%
  dplyr::mutate(item = str_remove_all(item, "^'([[:alpha:]]*(.)*?)*'[[:blank:]]*")) %>%
  dplyr::mutate(ds_tidy = str_remove_all(descricao, '^[0-9]+,[0-9]+ [A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ\'\\.]* +([0-9]+,[0-9]+ [A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ\'\\.]* +)?')) %>%
  dplyr::mutate(ds_tidy = str_remove_all(ds_tidy, "^( )*([$]|-|_|,|@|[.]|'|#|])*( )?")) %>%
  dplyr::mutate(ds_tidy = str_remove_all(ds_tidy, "\\((( )?([0-9]+|U(N)?|ITEM [0-9]+( DO TR)?)|([0-9]{2,}\\/[0-9]{2,}\\/[0-9]{4,}#[0-9]+))\\)( )?")) %>%
  dplyr::mutate(ds_tidy = str_replace_all(ds_tidy, '((\r|\n|\t)|( ){2,})+', ' ')) %>%
  dplyr::mutate(ds_item = case_when(
    !is.na(item) ~ if_else(tolower(item) == tolower(descricao_restante), 
                           str_glue("{item} {marca}"), 
                           str_glue("{item} {marca} {descricao_restante}")),
    TRUE ~ ds_tidy
  ))

valores_itens_empenhos_relacionados <- itens_empenhos_relacionados %>%
  mutate(valor_total = ifelse(Espécie == "ANULAÇÃO", valor_total * -1, valor_total)) %>%
  group_by(codigo_empenho, ds_item) %>%
  mutate(valor_itens_empenhos_relacionados = sum(valor_total)) %>%
  ungroup() %>% 
  distinct(codigo_empenho, ds_item, .keep_all = TRUE) %>%
  filter(!is.na(descricao)) %>%
  filter(valor_itens_empenhos_relacionados >= 0) %>% 
  select(codigo_empenho, ds_item, valor_itens_empenhos_relacionados)

contratos_processados <- read_contratos_processados() %>% 
  select(id_contrato, codigo_contrato)

item_processados <- read_itens_contrato_processados()

item_processados_b <- item_processados %>% 
  left_join(contratos_processados, by = c("id_contrato"))

itens_match <- item_processados_b %>%
  left_join(valores_itens_empenhos_relacionados, by = c("codigo_contrato" = "codigo_empenho", "ds_item")) %>%
  mutate(tem_inconsistencia = !is.na(valor_itens_empenhos_relacionados)) %>% 
  select(id_item_contrato, id_contrato, id_orgao, cd_orgao, id_licitacao, id_item_licitacao, nr_lote, 
         nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato, 
         nr_item, qt_itens_contrato, vl_item_contrato, vl_total_item_contrato, origem_valor, tem_inconsistencia,
         sigla_estado, id_estado, dt_inicio_vigencia, ds_item, 
         sg_unidade_medida, categoria, language, ds_1, ds_2, ds_3, servico, valor_calculado = valor_itens_empenhos_relacionados)

if (nrow(itens_match) != nrow(item_processados)) {
  flog.error("Erro na atualização dos valores dos itens: número de itens inválido")
  stop("Erro na atualização dos valores dos itens: número de itens inválido")
}

write_csv(itens_match, here::here("./data/bd/info_item_contrato.csv"))