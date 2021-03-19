library(tidyverse)
library(here)
library(magrittr)

help <- "
Usage:
Rscript export_dados_bd.R <anos> <filtro>
<anos> pode ser um ano (2017) ou múltiplos anos separados por vírgula (2017,2018,2019)
<filtro> pode ser merenda ou covid
Exemplos:
Rscript export_dados_bd.R 2019 merenda
Rscript export_dados_bd.R 2018,2019,2020 merenda
"

args <- commandArgs(trailingOnly = TRUE)
min_num_args <- 2
if (length(args) < min_num_args) {
  stop(paste("Wrong number of arguments!", help, sep = "\n"))
}

anos <- unlist(strsplit(args[1], split=","))
# anos = c(2020)
filtro <- args[2]
# filtro <- "merenda"

source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/constants.R"))

source(here::here("transformer/processor/estados/RS/licitacoes/processador_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/RS/orgaos/processador_orgaos_rs.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_licitantes_rs.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_itens_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_documentos_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_contratos_rs.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_eventos_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_lotes_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_itens_contratos_rs.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_compras_rs.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_fornecedores_contratos_rs.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_alteracoes_contratos_rs.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_tipos_alteracoes_contratos_rs.R"))

## Assume que os dados foram baixados usando o módulo do crawler de dados (presente no diretório crawler
## na raiz desse repositório)

# Processamento dos dados
message("#### Iniciando processamento...")

#--------------------------------- Processamento das tabelas do Rio Grande do Sul-------------------------------------------

## Licitações
message("#### licitações...")
licitacoes_rs <- processa_licitacoes_rs(anos, filtro)

## Órgãos --------------------------------------------------------------------------
message("#### órgãos")
info_orgaos_rs <- processa_orgaos_rs(anos, filtro)

## Licitantes ----------------------------------------------------------------------
message("### licitantes...")
licitantes_rs <- processa_licitantes_rs(anos)

## Itens de licitações -------------------------------------------------------------
message("#### itens de licitações...")
itens_licitacao_rs <- processa_itens_licitacoes_rs(anos)

## Documentos de licitações --------------------------------------------------------
message("#### Documentos de licitações...")
documento_licitacao_rs <- processa_documentos_licitacoes_rs(anos)

## Contratos ------------------------------------------------------------------------
message("#### contratos...")
contratos_rs <- processa_contratos_rs(anos)

## *Compras* ----------------------------------------------------------------------------
message("#### licitações encerradas...")
licitacoes_encerradas_rs <- processa_eventos_licitacoes_rs(anos)

message("#### lotes de licitação...")
lotes_licitacoes_rs <- processa_lotes_licitacoes_rs(anos)

### Itens de contratos e licitação -------------------------------------------------------
message("#### preparando dados de itens de licitação e contratos...")
itens_contrato <- processa_itens_contrato_rs(anos)
itens_licitacao <- processa_itens_licitacoes_renamed_columns_rs()

message("#### processando compras...")
compras_rs <- processa_compras_rs(anos, licitacoes_encerradas_rs, lotes_licitacoes_rs, itens_licitacao, itens_contrato)

message("#### itens com contratos...")
itens_contrato <- processa_itens_contratos_renamed_columns_rs()

message("#### itens sem contratos...")
itens_comprados <- processa_item_licitacao_comprados_rs(anos, compras_rs, itens_contrato)

message("#### processando todos os itens comprados...")
itens_contratos_rs <- processa_todos_itens_comprados(itens_comprados)

## Fornecedores nos contratos --------------------------------------------------------------
message("#### fornecedores (contratos)...")
fornecedores_contratos_rs <- processa_fornecedores_contrato_rs(anos, contratos_rs, compras_rs)

## Alterações contratos --------------------------------------------------------------------
message("#### alterações de contratos...")
alteracoes_rs <- processa_alteracoes_contratos_rs(anos)
tipo_operacao_alteracao <- processa_tipos_alteracoes_contratos_rs(anos)

#--------------------------------- Processamento das tabelas de Pernambuco-------------------------------------------

source(here::here("transformer/adapter/estados/PE/licitacoes/adaptador_licitacoes_pe.R"))
source(here::here("transformer/adapter/estados/PE/orgaos/adaptador_orgaos_pe.R"))
source(here::here("transformer/adapter/estados/PE/contratos/adaptador_fornecedores_contratos_pe.R"))
source(here::here("transformer/adapter/estados/PE/contratos/adaptador_contratos_pe.R"))

info_orgaos_pe <- import_orgaos_municipais_pe() %>%
  adapta_info_orgaos_pe(import_orgaos_estaduais_pe(), import_municipios_pe()) %>%
  add_info_estado(sigla_estado = "PE", id_estado = "26")

licitacoes_pe <- import_licitacoes_pe() %>%
  adapta_info_licitacoes_pe(tipo_filtro = filtro) %>%
  add_info_estado(sigla_estado = "PE", id_estado = "26")

contratos_pe <- import_contratos_pe() %>% 
  adapta_info_contratos_pe() %>%
  add_info_estado(sigla_estado = "PE", id_estado = "26") 

fornecedores_contratos_pe <- import_fornecedores_pe() %>%
  adapta_info_fornecedores_pe(contratos_pe) %>%
  add_info_estado(sigla_estado = "PE", id_estado = "26")
  

#---------------------------------------------- Agregador------------------------------------------------------------


info_orgaos <- bind_rows(info_orgaos_rs,
                         info_orgaos_pe) %>%
  generate_hash_id(c("cd_orgao", "id_estado"),
                   O_ID) %>%
  dplyr::select(id_orgao, dplyr::everything())

licitacoes_falsos_positivos <- readr::read_csv(here::here("transformer/utils/files/licitacoes_falsos_positivos.csv"))

info_licitacoes <- bind_rows(licitacoes_rs,
                             licitacoes_pe)  %>% 
  left_join(info_orgaos %>% select(id_orgao, cd_orgao, id_estado)) %>% 
  distinct() %>% 
  generate_hash_id(c("id_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade"),
                   L_ID) %>%
  dplyr::select(id_licitacao, id_estado, id_orgao, dplyr::everything()) %>%
  dplyr::filter(!id_licitacao %in% (licitacoes_falsos_positivos %>% pull(id_licitacao)))


info_licitantes <- join_licitante_e_licitacao(
  licitantes_rs,
  info_licitacoes %>%
    dplyr::select(id_estado, id_orgao, cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, id_licitacao)
) %>%
  generate_hash_id(c("id_licitacao", "tp_documento_licitante", "nr_documento_licitante"), LICITANTE_ID) %>%
  dplyr::select(id_licitante, id_estado, id_orgao, id_licitacao, dplyr::everything())
  
info_contratos <- bind_rows(contratos_pe, contratos_rs) %>% 
    join_contrato_e_licitacao(info_licitacoes %>%
                                dplyr::select(cd_orgao,
                                              nr_licitacao,
                                              ano_licitacao,
                                              cd_tipo_modalidade,
                                              id_licitacao, 
                                              id_orgao,
                                              id_estado)) %>% 
  generate_hash_id(c("id_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade",
                      "nr_contrato", "ano_contrato", "tp_instrumento_contrato"), CONTRATO_ID) %>%
   dplyr::select(id_contrato, id_estado, id_orgao, id_licitacao, dplyr::everything())
  

info_item_licitacao <- itens_licitacao_rs %>%
  left_join(info_orgaos %>% select(id_orgao, cd_orgao, id_estado)) %>% 
  join_licitacoes_e_itens(info_licitacoes) %>%
  distinct() %>% 
  generate_hash_id(c("cd_orgao", "ano_licitacao", "nr_licitacao",
                     "cd_tipo_modalidade", "nr_lote", "nr_item"),
                   I_ID) %>%
  dplyr::select(id_item, id_licitacao, id_orgao, dplyr::everything())

info_documento_licitacao <- documento_licitacao_rs %>%
  left_join(info_orgaos %>% select(id_orgao, cd_orgao, id_estado)) %>% 
  join_licitacoes_e_documentos(info_licitacoes) %>%
  join_documento_e_tipo(tipos_documento_licitacao) %>%
  generate_hash_id(c("cd_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade",
                     "cd_tipo_documento", "nome_arquivo_documento",
                     "cd_tipo_fase", "id_evento_licitacao", "tp_documento", "nr_documento"),
                   DOC_LIC_ID) %>%
  dplyr::select(id_documento_licitacao, id_licitacao, id_orgao, dplyr::everything())

info_compras <- compras_rs %>%
  dplyr::left_join(info_licitacoes %>%
                     dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade,
                                   id_licitacao, nm_orgao),
                   by = c("cd_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade")) %>%
  dplyr::filter(!is.na(id_licitacao)) %>%
  generate_hash_id(c("cd_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade",
                     "nr_contrato", "ano_contrato", "tp_instrumento_contrato"), CONTRATO_ID) %>%
  dplyr::distinct(id_licitacao, id_contrato, .keep_all = TRUE) %>%
  dplyr::select(id_contrato, id_licitacao, cd_orgao, nr_contrato, ano_contrato, nm_orgao,
                nr_licitacao, ano_licitacao, cd_tipo_modalidade,
                dt_inicio_vigencia, vl_contrato,
                descricao_objeto_contrato = ds_objeto,
                tp_instrumento_contrato,
                dt_inicio_vigencia,
                tipo_instrumento_contrato,
                tp_documento_contratado = tp_fornecedor,
                nr_documento_contratado = nr_fornecedor) %>% 
  add_info_estado(sigla_estado = "RS", id_estado = "43")

info_contratos %<>% dplyr::bind_rows(info_compras) %>%
  dplyr::mutate(language = 'portuguese')


info_item_contrato <- itens_contratos_rs %>%
  left_join(info_orgaos %>% select(id_orgao, cd_orgao, id_estado)) %>% 
  join_contratos_e_itens(info_contratos %>%
                           dplyr::select(dt_inicio_vigencia, cd_orgao, id_contrato, nr_licitacao, ano_licitacao,
                                         cd_tipo_modalidade, nr_contrato, ano_contrato,
                                         tp_instrumento_contrato)) %>%
  generate_hash_id(c("cd_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade", "nr_contrato", "ano_contrato",
                     "tp_instrumento_contrato", "nr_lote", "nr_item"), ITEM_CONTRATO_ID) %>%
  join_licitacoes_e_itens(info_licitacoes) %>%
  join_itens_contratos_e_licitacoes(info_item_licitacao) %>%
  dplyr::ungroup() %>%
  dplyr::select(id_item_contrato, id_contrato, id_orgao, cd_orgao, id_licitacao, id_item_licitacao, dplyr::everything()) %>%
  create_categoria() %>%
  split_descricao() %>%
  dplyr::ungroup() %>%
  marca_servicos()

info_fornecedores_contratos <- bind_rows(fornecedores_contratos_rs,
                                         fornecedores_contratos_pe) %>%
  join_contratos_e_fornecedores(info_contratos %>%
                                  dplyr::select(nr_documento_contratado)) %>%
  dplyr::distinct(nr_documento, .keep_all = TRUE) %>%
  dplyr::select(nr_documento, id_estado, nm_pessoa, tp_pessoa, total_de_contratos, data_primeiro_contrato)

info_alteracoes_contrato <- alteracoes_rs %>%
  left_join(info_orgaos %>% select(id_orgao, cd_orgao, id_estado)) %>% 
  join_alteracoes_contrato_e_tipo(tipo_operacao_alteracao) %>%
  join_alteracoes_contrato_e_contrato(info_contratos) %>%
  generate_hash_id(c("cd_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade", "nr_contrato", "ano_contrato",
                     "tp_instrumento_contrato", "id_evento_contrato", "cd_tipo_operacao"), ALTERACOES_CONTRATO_ID) %>%
  dplyr::select(id_alteracoes_contrato, id_contrato, id_orgao, dplyr::everything())


#----------------------------------------------- # Escrita dos dados-------------------------------------------------
message("#### escrevendo dados...")

readr::write_csv(info_licitacoes, here("data/bd/info_licitacao.csv"))
readr::write_csv(info_licitantes, here("data/bd/info_licitante.csv"))
readr::write_csv(info_item_licitacao, here("data/bd/info_item_licitacao.csv"))
readr::write_csv(info_documento_licitacao, here("data/bd/info_documento_licitacao.csv"))
readr::write_csv(info_contratos, here("data/bd/info_contrato.csv"))
readr::write_csv(info_fornecedores_contratos, here("data/bd/info_fornecedores_contrato.csv"))
readr::write_csv(info_item_contrato, here("data/bd/info_item_contrato.csv"))
readr::write_csv(info_alteracoes_contrato, here("data/bd/info_alteracao_contrato.csv"))
readr::write_csv(info_orgaos, here("data/bd/info_orgaos.csv"))

message("#### Processamento concluído!")
message("#### Confira o diretório data/bd")
