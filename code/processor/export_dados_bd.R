library(tidyverse)
library(here)

## Assume que os dados foram baixados usando o módulo do crawler de dados (presente no diretório crawler
## na raiz desse repositório)

anos = c(2017, 2018, 2019)

# Processamento dos dados
message("#### Iniciando processamento...")

## Licitações
message("#### licitações...")
source(here("code/licitacoes/processa_licitacoes.R"))
info_licitacoes <- processa_info_licitacoes(anos)

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
write_csv(info_licitacoes, here("data/bd/info_licitacao.csv"))
write_csv(info_item_licitacao, here("data/bd/info_item_licitacao.csv"))
write_csv(info_contratos, here("data/bd/info_contrato.csv"))
write_csv(info_item_contrato, here("data/bd/info_item_contrato.csv"))
write_csv(info_alteracoes_contrato, here("data/bd/info_alteracao_contrato.csv"))
write_csv(info_municipios, here("data/bd/info_municipio.csv"))
write_csv(info_estados, here("data/bd/info_estado.csv"))

message("#### Processamento concluído!")
message("#### Confira o diretório data/bd")