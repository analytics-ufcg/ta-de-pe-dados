library(tidyverse)
library(here)
library(magrittr)
library(futile.logger)

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

source(here::here("transformer/processor/estados/PE/orgaos/processador_orgaos_pe.R"))
source(here::here("transformer/processor/estados/PE/licitacoes/processador_licitacoes_pe.R"))
source(here::here("transformer/processor/estados/PE/contratos/processador_contratos_pe.R"))
source(here::here("transformer/processor/estados/PE/contratos/processador_fornecedores_contratos_pe.R"))
source(here::here("transformer/processor/estados/PE/contratos/processador_itens_contratos_pe.R"))
## Assume que os dados foram baixados usando o módulo do crawler de dados (presente no diretório crawler
## na raiz desse repositório)

# Processamento dos dados
flog.info("#### Iniciando processamento...")

#--------------------------------- Processamento das tabelas do Rio Grande do Sul-------------------------------------------
flog.info("#### Processando infos. do RS...")

## Licitações
flog.info("#### licitações...")
licitacoes_rs <- processa_licitacoes_rs(anos, filtro)

## Órgãos --------------------------------------------------------------------------
flog.info("#### órgãos")
info_orgaos_rs <- processa_orgaos_rs(anos, filtro)

## Licitantes ----------------------------------------------------------------------
flog.info("### licitantes...")
licitantes_rs <- processa_licitantes_rs(anos)

## Itens de licitações -------------------------------------------------------------
flog.info("#### itens de licitações...")
itens_licitacao_rs <- processa_itens_licitacoes_rs(anos)

## Documentos de licitações --------------------------------------------------------
flog.info("#### Documentos de licitações...")
tipos_documento_licitacao_rs <- processa_tipos_documentos_licitacoes_rs()
documento_licitacao_rs <- processa_documentos_licitacoes_rs(anos)

## Contratos ------------------------------------------------------------------------
flog.info("#### contratos...")
contratos_rs <- processa_contratos_rs(anos)

## *Compras* ----------------------------------------------------------------------------
flog.info("#### licitações encerradas...")
licitacoes_encerradas_rs <- processa_eventos_licitacoes_rs(anos)

flog.info("#### lotes de licitação...")
lotes_licitacoes_rs <- processa_lotes_licitacoes_rs(anos)

### Itens de contratos e licitação -------------------------------------------------------
flog.info("#### preparando dados de itens de licitação e contratos...")
itens_contrato <- processa_itens_contrato_rs(anos)
itens_licitacao <- processa_itens_licitacoes_renamed_columns_rs()

flog.info("#### processando compras...")
compras_rs <- processa_compras_rs(anos, licitacoes_encerradas_rs, lotes_licitacoes_rs, itens_licitacao, itens_contrato)

flog.info("#### itens com contratos...")
itens_contrato <- processa_itens_contratos_renamed_columns_rs(itens_contrato)

flog.info("#### itens sem contratos...")
itens_comprados <- processa_item_licitacao_comprados_rs(anos, compras_rs, itens_contrato)

flog.info("#### processando todos os itens comprados...")
itens_contratos_rs <- processa_todos_itens_comprados(itens_comprados, itens_licitacao_rs %>%
                                                       select("ds_item", "sg_unidade_medida", "cd_orgao", 
                                                              "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade", 
                                                              "nr_lote", "nr_item"))

## Fornecedores nos contratos --------------------------------------------------------------
flog.info("#### fornecedores (contratos)...")
fornecedores_contratos_rs <- processa_fornecedores_contrato_rs(anos, contratos_rs, compras_rs)

## Alterações contratos --------------------------------------------------------------------
flog.info("#### alterações de contratos...")
tipo_operacao_alteracao <- processa_tipos_alteracoes_contratos_rs(anos)

#--------------------------------- Processamento das tabelas de Pernambuco-------------------
flog.info("#### Processando infos. de PE...")
# Órgãos ------------------------------------------------------------------------------------
flog.info("#### órgãos...")
info_orgaos_pe <- processa_orgaos_pe()

# Licitacoes  -------------------------------------------------------------------------------
flog.info("#### Licitações...")
licitacoes_pe <- processa_licitacoes_pe(filtro)

# Contratos  --------------------------------------------------------------------------------
flog.info("#### Contratos...")
contratos_pe <- processa_contratos_pe()

# Fornecedores contratos  -------------------------------------------------------------------
flog.info("#### Fornecedores contratos...")
fornecedores_contratos_pe <- processa_fornecedores_contratos_pe(contratos_pe)

# Itens dos contratos  -------------------------------------------------------------------
flog.info("#### Itens contratos...")
itens_contratos_pe <- processa_itens_contrato_pe(contratos_pe, licitacoes_pe)

#---------------------------------------------- Agregador------------------------------------------------------------

info_orgaos <- bind_rows(info_orgaos_rs,
                         info_orgaos_pe) %>%
  generate_hash_id(c("cd_orgao", "id_estado"),
                   O_ID) %>%
  dplyr::mutate(cd_municipio_ibge = dplyr::if_else(stringr::str_detect(nome_municipio, "ESTADO"), 
                                            id_estado,
                                            cd_municipio_ibge)) %>% 
  dplyr::select(id_orgao, dplyr::everything())

info_municipios_monitorados <- info_orgaos %>% 
  dplyr::select(cd_municipio_ibge, nome_municipio, id_estado, sigla_estado) %>% 
  dplyr::mutate(slug_municipio = tolower(paste0(gsub(" ", "-", iconv(nome_municipio,from="UTF-8",to="ASCII//TRANSLIT")),
                                                "-",
                                                sigla_estado
                                                ))) %>%
  dplyr::mutate(nome_municipio = stringr::str_to_title(nome_municipio)) %>% 
  dplyr::distinct(cd_municipio_ibge, .keep_all = TRUE)

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
  join_documento_e_tipo(tipos_documento_licitacao_rs) %>%
  generate_hash_id(c("cd_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade",
                     "cd_tipo_documento", "nome_arquivo_documento",
                     "cd_tipo_fase", "id_evento_licitacao", "tp_documento", "nr_documento"),
                   DOC_LIC_ID) %>%
  dplyr::select(id_documento_licitacao, id_licitacao, id_orgao, dplyr::everything())

info_compras <- compras_rs %>%
  dplyr::left_join(info_licitacoes %>%
                     dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, id_estado,
                                   id_licitacao, id_orgao, nm_orgao),
                   by = c("cd_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade", "id_estado")) %>%
  dplyr::filter(!is.na(id_licitacao)) %>%
  generate_hash_id(c("id_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade",
                     "nr_contrato", "ano_contrato", "tp_instrumento_contrato"), CONTRATO_ID) %>%
  dplyr::distinct(id_licitacao, id_contrato, .keep_all = TRUE) %>%
  dplyr::select(id_contrato, id_licitacao, id_orgao, cd_orgao, nr_contrato, ano_contrato, nm_orgao,
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
  dplyr::mutate(language = 'portuguese') %>% 
  distinct(id_contrato, .keep_all = TRUE)


info_item_contrato <- itens_contratos_rs %>%
  dplyr::bind_rows(itens_contratos_pe) %>%
  left_join(info_orgaos %>% select(id_orgao, cd_orgao, id_estado),
            by = c("cd_orgao", "id_estado")) %>% 
  join_contratos_e_itens(info_contratos %>%
                           dplyr::select(dt_inicio_vigencia, cd_orgao, id_contrato, nr_licitacao, ano_licitacao,
                                         cd_tipo_modalidade, nr_contrato, ano_contrato,
                                         tp_instrumento_contrato)) %>%
  generate_hash_id(c("id_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade", "nr_contrato", "ano_contrato",
                     "tp_instrumento_contrato", "nr_lote", "nr_item"), ITEM_CONTRATO_ID) %>%
  join_licitacoes_e_itens(info_licitacoes) %>%
  join_itens_contratos_e_licitacoes(info_item_licitacao) %>%
  dplyr::ungroup() %>%
  dplyr::select(id_item_contrato, id_contrato, id_orgao, cd_orgao, id_licitacao, id_item_licitacao, dplyr::everything()) %>%
  create_categoria() %>%
  split_descricao() %>%
  dplyr::ungroup() %>%
  marca_servicos() %>% 
  select(id_item_contrato, id_contrato, id_orgao, cd_orgao, id_licitacao, id_item_licitacao, nr_lote, 
         nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato, 
         nr_item, qt_itens_contrato, vl_item_contrato, vl_total_item_contrato, origem_valor, sigla_estado, id_estado, dt_inicio_vigencia, ds_item, 
         sg_unidade_medida, categoria, language, ds_1, ds_2, ds_3, servico)

info_fornecedores_contratos <- bind_rows(fornecedores_contratos_rs,
                                         fornecedores_contratos_pe) %>%
  join_contratos_e_fornecedores(info_contratos %>%
                                  dplyr::select(nr_documento_contratado)) %>%
  dplyr::distinct(nr_documento, id_estado, .keep_all = TRUE) %>% 
  dplyr::group_by(nr_documento) %>% 
  dplyr::mutate(total_de_contratos = sum(total_de_contratos, na.rm = T),
                data_primeiro_contrato = min(data_primeiro_contrato, na.rm = T)) %>% 
  dplyr::distinct(nr_documento, .keep_all = TRUE) %>%
  dplyr::select(nr_documento, id_estado, nm_pessoa, tp_pessoa, total_de_contratos, data_primeiro_contrato)



#----------------------------------------------- # Escrita dos dados-------------------------------------------------
flog.info("#### escrevendo dados...")

output_transformer <- here("data/bd/")

if (!dir.exists(output_transformer)){
  dir.create(output_transformer, recursive = TRUE)
}

readr::write_csv(info_licitacoes, paste0(output_transformer, "info_licitacao.csv"))
readr::write_csv(info_licitantes, paste0(output_transformer, "info_licitante.csv"))
readr::write_csv(info_item_licitacao, paste0(output_transformer, "info_item_licitacao.csv"))
readr::write_csv(info_documento_licitacao, paste0(output_transformer, "info_documento_licitacao.csv"))
readr::write_csv(info_contratos, paste0(output_transformer, "info_contrato.csv"))
readr::write_csv(info_fornecedores_contratos, paste0(output_transformer, "info_fornecedores_contrato.csv"))
readr::write_csv(info_item_contrato, paste0(output_transformer, "info_item_contrato.csv"))
readr::write_csv(info_orgaos, paste0(output_transformer, "info_orgaos.csv"))
readr::write_csv(info_municipios_monitorados, paste0(output_transformer, "info_municipios_monitorados.csv"))

flog.info("#### Processamento concluído!")
flog.info(paste("#### Confira o diretório", output_transformer))
