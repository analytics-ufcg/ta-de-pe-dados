library(tidyverse)
library(here)
library(magrittr)

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
source(here::here("code/utils/join_utils.R"))
source(here::here("code/utils/constants.R"))

## Assume que os dados foram baixados usando o módulo do crawler de dados (presente no diretório crawler
## na raiz desse repositório)

anos = c(2019)

# Processamento dos dados
message("#### Iniciando processamento...")

## Licitações
message("#### licitações...")
source(here::here("code/licitacoes/processa_licitacoes.R"))
source(here::here("code/licitacoes/processa_tipos_licitacoes.R"))
licitacoes <- import_licitacoes(anos) %>% 
  processa_info_licitacoes()
tipo_licitacao <- processa_tipos_licitacoes()
info_licitacoes <- join_licitacao_e_tipo(licitacoes, tipo_licitacao) %>% 
  generate_id(TABELA_LICITACAO, L_ID) %>% 
  dplyr::select(id_licitacao, dplyr::everything())

## Itens de licitações
message("#### itens de licitações...")
source(here::here("code/licitacoes/processa_itens_licitacao.R"))
info_item_licitacao <- import_itens_licitacao(anos) %>%
  processa_info_item_licitacao() %>% 
  generate_id(TABELA_ITEM, I_ID) %>% 
  join_licitacoes_e_itens(info_licitacoes) %>% 
  dplyr::select(id_item, id_licitacao, dplyr::everything())

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
source(here::here("code/orgaos/processa_orgaos.R"))
info_orgaos <- import_licitacoes(anos) %>% 
  processa_info_orgaos()

## Estados
message("#### estados...")
source(here::here("code/orgaos/processa_estados.R"))
info_estados <- processa_info_estados()


# Escrita dos dados

message("#### escrevendo dados...")
write_csv(info_licitacoes, here("data/bd/info_licitacao.csv"))
write_csv(info_item_licitacao, here("data/bd/info_item_licitacao.csv"))
write_csv(info_contratos, here("data/bd/info_contrato.csv"))
write_csv(info_item_contrato, here("data/bd/info_item_contrato.csv"))
write_csv(info_alteracoes_contrato, here("data/bd/info_alteracao_contrato.csv"))
write_csv(info_orgaos, here("data/bd/info_orgaos.csv"))
write_csv(info_estados, here("data/bd/info_estados.csv"))

message("#### Processamento concluído!")
message("#### Confira o diretório data/bd")