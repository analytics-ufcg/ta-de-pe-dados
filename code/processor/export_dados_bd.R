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
# anos = c(2018, 2019, 2020)
filtro <- args[2]
# filtro <- "merenda"

source(here::here("code/utils/utils.R"))
source(here::here("code/utils/join_utils.R"))
source(here::here("code/utils/constants.R"))

## Assume que os dados foram baixados usando o módulo do crawler de dados (presente no diretório crawler
## na raiz desse repositório)

# Processamento dos dados
message("#### Iniciando processamento...")

## Órgãos
message("#### órgãos")
source(here::here("code/orgaos/processa_orgaos.R"))
source(here::here("code/orgaos/processa_orgaos_pe.R"))

info_orgaos_municipios <- import_orgaos() %>%
  processa_info_orgaos()


municipios_pe <- import_municipios_pe()
orgaos_estaduais_pe <- import_orgaos_estaduais_pe()
info_orgaos_pe <- import_orgaos_municipais_pe() %>%
  processa_info_orgaos_pe(orgaos_estaduais_pe, municipios_pe)

## Licitações
message("#### licitações...")
source(here::here("code/licitacoes/processa_licitacoes.R"))
source(here::here("code/licitacoes/processa_tipos_licitacoes.R"))
source(here::here("code/licitacoes/processa_tipos_modalidade_licitacoes.R"))
source(here::here("code/licitacoes/processa_licitacoes_pe.R"))

licitacoes_falsos_positivos <- readr::read_csv(here::here("code/utils/licitacoes_falsos_positivos.csv"))

licitacoes_raw <- import_licitacoes(anos)

licitacoes <- licitacoes_raw %>%
  processa_info_licitacoes(tipo_filtro = filtro)

orgaos_licitacao <- licitacoes %>%
  dplyr::distinct(id_orgao, nm_orgao)

## Completa CSV de órgãos com os órgãos presentes na tabela de licitação --- REFATORAR
info_orgaos <- info_orgaos_municipios %>%
  dplyr::mutate(id_orgao = as.character(id_orgao)) %>%
  dplyr::bind_rows(orgaos_licitacao %>%
                     dplyr::mutate(esfera = "ESTADUAL")) %>%
  dplyr::distinct(id_orgao, .keep_all = TRUE) %>%
  dplyr::mutate(nome_entidade = nome_municipio) %>%
  dplyr::mutate(nome_municipio = dplyr::if_else(esfera == "ESTADUAL",
                                                "ESTADO DO RIO GRANDE DO SUL",
                                                nome_municipio)) %>%
  dplyr::mutate(sigla_estado = "RS", id_estado = "43") %>%
  dplyr::bind_rows(info_orgaos_pe %>%
                     dplyr::mutate(cd_municipio_ibge = as.numeric(cd_municipio_ibge))) %>%
  generate_hash_id(c("id_orgao", "sigla_estado"),
                   O_ID) %>%
  dplyr::select(id_orgao, dplyr::everything())


tipo_licitacao <- processa_tipos_licitacoes()
tipo_modalidade_licitacao <- processa_tipos_modalidade_licitacoes()

licitacoes_pe <- import_licitacoes_pe() %>%
  processa_info_licitacoes_pe(tipo_filtro = filtro)

licitacoes_rs <- join_licitacao_e_tipo(licitacoes, tipo_licitacao) %>%
  join_licitacao_e_tipo_modalidade(tipo_modalidade_licitacao)

info_licitacoes <- licitacoes_rs %>%
  dplyr::bind_rows(licitacoes_pe) %>%
  dplyr::select(-id_orgao) %>%
  dplyr::left_join(info_orgaos %>%
                     dplyr::select(id_orgao, nm_orgao, id_estado)) %>%
  generate_hash_id(c("id_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade"),
                   L_ID) %>%
  dplyr::select(id_licitacao, id_estado, id_orgao, dplyr::everything()) %>%
  dplyr::filter(!id_licitacao %in% (licitacoes_falsos_positivos %>% pull(id_licitacao)))

## Licitantes
message("### licitantes...")

source(here::here("code/licitacoes/processa_licitantes.R"))

licitantes <- import_licitantes(anos) %>%
  processa_info_licitantes()

info_licitantes <- join_licitante_e_licitacao(
  licitantes,
  info_licitacoes %>%
    dplyr::select(id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, L_ID)
) %>%
  generate_hash_id(c("id_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade",
                     "tp_documento_licitante", "nr_documento_licitante"), LICITANTE_ID) %>%
  dplyr::select(id_licitante, id_licitacao, dplyr::everything())

## Itens de licitações
message("#### itens de licitações...")
source(here::here("code/licitacoes/processa_itens_licitacao.R"))

itens_licitacao_raw <- import_itens_licitacao(anos)

info_item_licitacao <- itens_licitacao_raw %>%
  processa_info_item_licitacao() %>%
  join_licitacoes_e_itens(info_licitacoes) %>%
  generate_hash_id(c("id_orgao", "ano_licitacao", "nr_licitacao",
                     "cd_tipo_modalidade", "nr_lote", "nr_item"),
                   I_ID) %>%
  dplyr::select(id_item, id_licitacao, dplyr::everything())

## Documentos de licitações
message("#### Documentos de licitações...")
source(here::here("code/licitacoes/processa_documentos_licitacao.R"))
source(here::here("code/licitacoes/processa_tipos_documentos_licitacoes.R"))

tipos_documento_licitacao <- processa_tipos_documento_licitacoes()

info_documento_licitacao <- import_documentos_licitacoes(anos) %>%
  processa_info_documentos_licitacoes() %>%
  join_licitacoes_e_documentos(info_licitacoes) %>%
  join_documento_e_tipo(tipos_documento_licitacao) %>%
  generate_hash_id(c("id_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade",
                     "cd_tipo_documento", "nome_arquivo_documento",
                     "cd_tipo_fase", "id_evento_licitacao", "tp_documento", "nr_documento"),
                   DOC_LIC_ID) %>%
  dplyr::select(id_documento_licitacao, id_licitacao, dplyr::everything())

## Contratos
message("#### contratos...")
source(here::here("code/contratos/processa_contratos.R"))
source(here::here("code/contratos/processa_tipos_instrumento_contrato.R"))
source(here::here("code/contratos/processa_contratos_pe.R"))

contratos <- import_contratos(anos) %>%
  processa_info_contratos()

tipo_instrumento_contrato <-
  processa_tipos_instrumento_contrato()

info_contratos <-
  join_contrato_e_licitacao(contratos,
                            info_licitacoes %>%
                              dplyr::select(id_orgao,
                                            nr_licitacao,
                                            ano_licitacao,
                                            cd_tipo_modalidade,
                                            id_licitacao)) %>%

  join_contrato_e_instrumento(tipo_instrumento_contrato) %>%
  generate_hash_id(c("id_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade",
                     "nr_contrato", "ano_contrato", "tp_instrumento_contrato"), CONTRATO_ID) %>%
  dplyr::select(id_contrato, id_licitacao, id_orgao, dplyr::everything())

contratos_pe <- import_contratos_pe()

info_contratos_pe <- processa_info_contratos_pe(contratos_pe) %>%
  separate(vigencia, c("dt_inicio_vigencia", "dt_final_vigencia"), " a ")


## Compras
message("#### licitações encerradas...")
source(here("code/licitacoes/processa_eventos_licitacoes.R"))

licitacoes_encerradas <- import_eventos_licitacoes(anos) %>%
  filtra_licitacoes_encerradas() %>%
  dplyr::mutate(data_evento = as.POSIXct(data_evento, format="%Y-%m-%d")) %>%
  dplyr::mutate(dt_inicio_vigencia = data_evento)


message("#### lotes de licitação...")
source(here("code/licitacoes/processa_lotes_licitacao.R"))

lotes_licitacoes <- import_lotes_licitacao(anos) %>%
  processa_info_lote_licitacao()

### Itens de contratos e licitação
message("#### preparando dados de itens de licitação e contratos...")
source(here("code/contratos/processa_itens_contrato.R"))
source(here("code/licitacoes/processa_itens_licitacao.R"))

itens_contrato <- import_itens_contrato(anos)

itens_licitacao <- itens_licitacao_raw %>%
  rename_duplicate_columns()

message("#### processando compras e itens...")
source(here("code/contratos/processa_compras.R"))
compras <- processa_compras_itens(licitacoes_raw, licitacoes_encerradas,
                                  lotes_licitacoes, itens_licitacao,
                                  itens_contrato)


message("#### processando dataframe de compras...")
info_compras <- compras %>%
  dplyr::left_join(info_licitacoes %>%
                     dplyr::mutate(cd_orgao = id_orgao) %>%
                     dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade,
                                   id_licitacao, nm_orgao),
                   by = c("cd_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade")) %>%
  dplyr::filter(!is.na(id_licitacao)) %>%
  dplyr::rename(id_orgao = cd_orgao) %>%
  generate_hash_id(c("id_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade",
                     "nr_contrato", "ano_contrato", "tp_instrumento_contrato"), CONTRATO_ID) %>%
  dplyr::distinct(id_licitacao, id_contrato, .keep_all = TRUE) %>%
  dplyr::select(id_contrato, id_licitacao, id_orgao, nr_contrato, ano_contrato, nm_orgao,
                nr_licitacao, ano_licitacao, cd_tipo_modalidade,
                dt_inicio_vigencia, vl_contrato,
                descricao_objeto_contrato = ds_objeto,
                tp_instrumento_contrato,
                dt_inicio_vigencia,
                tipo_instrumento_contrato,
                tp_documento_contratado = tp_fornecedor,
                nr_documento_contratado = nr_fornecedor)

info_contratos %<>% dplyr::bind_rows(info_compras) %>%
  dplyr::mutate(language = 'portuguese')

### Itens Comprados
message("#### processando itens comprados...")

message("#### itens com contratos...")
itens_contrato <- itens_contrato %>%
  dplyr::mutate(ORIGEM_VALOR = "contrato")

message("#### itens sem contratos...")
itens_licitacao <- itens_licitacao_raw %>%
  processa_item_licitacao_comprado(compras)

colunas_item_contrato <- names(itens_contrato)
colunas_item_licitacao <- names(itens_licitacao)
intersecao <- Reduce(dplyr::intersect, list(colunas_item_contrato, colunas_item_licitacao))

itens_comprados <- itens_licitacao %>%
  dplyr::select(all_of(intersecao)) %>%
  dplyr::bind_rows(itens_contrato)

message("#### processando todos os itens comprados...")
info_item_contrato <- itens_comprados %>%
  processa_info_item_contrato() %>%
  join_contratos_e_itens(info_contratos %>%
                           dplyr::select(dt_inicio_vigencia, id_orgao, id_contrato, nr_licitacao, ano_licitacao,
                                         cd_tipo_modalidade, nr_contrato, ano_contrato,
                                         tp_instrumento_contrato)) %>%
  generate_hash_id(c("id_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade", "nr_contrato", "ano_contrato",
                     "tp_instrumento_contrato", "nr_lote", "nr_item"), ITEM_CONTRATO_ID) %>%
  join_licitacoes_e_itens(info_licitacoes) %>%
  join_itens_contratos_e_licitacoes(info_item_licitacao) %>%
  dplyr::ungroup() %>%
  dplyr::select(id_item_contrato, id_contrato, id_orgao, id_licitacao, id_item_licitacao, dplyr::everything()) %>%
  create_categoria() %>%
  split_descricao() %>%
  dplyr::ungroup() %>%
  marca_servicos()

## Fornecedores nos contratos
message("#### fornecedores (contratos)...")
source(here("code/contratos/processa_fornecedores.R"))
source(here("code/contratos/processa_fornecedores_pe.R"))

info_fornecedores_contratos <- import_fornecedores(anos) %>%
  processa_info_fornecedores(contratos, info_contratos) %>%
  join_contratos_e_fornecedores(info_contratos %>%
                                  dplyr::select(nr_documento_contratado)) %>%
  dplyr::distinct(nr_documento, .keep_all = TRUE) %>%
  dplyr::select(nr_documento, nm_pessoa, tp_pessoa, total_de_contratos, data_primeiro_contrato)

info_fornecedores_contratos_pe <- import_fornecedores_pe()

## Alterações contratos
message("#### alterações de contratos...")
source(here::here("code/contratos/processa_alteracoes_contratos.R"))
source(here::here("code/contratos/processa_tipos_alteracao_contrato.R"))

alteracoes <- import_alteracoes_contratos(anos) %>%
  processa_info_alteracoes_contratos()

tipo_operacao_alteracao <- processa_tipos_alteracao_contrato()

info_alteracoes_contrato <- alteracoes %>%
  join_alteracoes_contrato_e_tipo(tipo_operacao_alteracao) %>%
  join_alteracoes_contrato_e_contrato(info_contratos) %>%
  generate_hash_id(c("id_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade", "nr_contrato", "ano_contrato",
                     "tp_instrumento_contrato", "id_evento_contrato", "cd_tipo_operacao"), ALTERACOES_CONTRATO_ID) %>%
  dplyr::select(id_alteracoes_contrato, id_contrato, dplyr::everything())

# Escrita dos dados

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
