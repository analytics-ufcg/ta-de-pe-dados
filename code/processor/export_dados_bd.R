library(tidyverse)
library(here)

help <- "
Usage:
Rscript export_dados_bd.R <ano>
"

args <- commandArgs(trailingOnly = TRUE)
min_num_args <- 1
if (length(args) < min_num_args) {
  stop(paste("Wrong number of arguments!", help, sep = "\n"))
}

ano <- args[1]

source(here::here("code/utils/utils.R"))
source(here::here("code/utils/constants.R"))

## Assume que os dados foram baixados usando o módulo do crawler de dados (presente no diretório crawler
## na raiz desse repositório)

anos = c(2017, 2018, 2019, 2020)

# Processamento dos dados
message("#### Iniciando processamento...")

## Licitações
message("#### licitações...")

source(here::here("code/licitacoes/processa_licitacoes.R"))
source(here::here("code/licitacoes/processa_tipos_licitacoes.R"))
source(here::here("code/utils/join_utils.R"))

licitacoes <- read_licitacoes(ano) %>% 
  processa_info_licitacoes()
tipo_licitacao <- processa_tipos_licitacoes()

info_licitacoes <- join_licitacao_e_tipo(licitacoes, tipo_licitacao) %>% 
  generate_id(TABELA_LICITACAO, L_ID)

## Licitantes
message("### licitantes...")

source(here::here("code/licitacoes/processa_licitantes.R"))

licitantes <- import_licitantes_por_ano(ano) %>% 
  processa_info_licitantes()

info_licitantes <- join_licitante_e_licitacao(
  licitantes,
  info_licitacoes %>%
    dplyr::select(id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, L_ID)
) %>% 
  generate_id(TABELA_LICITANTE, LICITANTE_ID)

## Itens de licitações
message("#### itens de licitações...")
source(here("code/licitacoes/processa_itens_licitacao.R"))
info_item_licitacao <- processa_info_item_licitacao(anos)

## Contratos
message("#### contratos...")
source(here("code/contratos/processa_contratos.R"))
info_contratos <- processa_info_contratos(anos)

## Itens de contratos
message("#### itens de contratos...")
source(here("code/contratos/processa_itens_contrato.R"))
info_item_contrato <- processa_info_item_contrato(anos)

## Alterações contratos
message("#### alterações de contratos...")
source(here("code/contratos/processa_alteracoes_contratos.R"))
info_alteracoes_contrato <- processa_info_alteracoes_contratos(anos)

## Municípios
message("#### municípios...")
source(here("code/orgaos/processa_municipios.R"))
info_municipios <- processa_info_municipios()

## Estados
message("#### estados...")
source(here("code/orgaos/processa_estados.R"))
info_estados <- processa_info_estados()

# Escrita dos dados

message("#### escrevendo dados...")
readr::write_csv(info_licitacoes, here("data/bd/info_licitacao.csv"))
readr::write_csv(info_licitantes, here("data/bd/info_licitante.csv"))
readr::write_csv(info_item_licitacao, here("data/bd/info_item_licitacao.csv"))
readr::write_csv(info_contratos, here("data/bd/info_contrato.csv"))
readr::write_csv(info_item_contrato, here("data/bd/info_item_contrato.csv"))
readr::write_csv(info_alteracoes_contrato, here("data/bd/info_alteracao_contrato.csv"))
readr::write_csv(info_municipios, here("data/bd/info_municipio.csv"))
readr::write_csv(info_estados, here("data/bd/info_estado.csv"))

message("#### Processamento concluído!")
message("#### Confira o diretório data/bd")