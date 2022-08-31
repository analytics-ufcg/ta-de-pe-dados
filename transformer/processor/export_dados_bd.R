library(tidyverse)
library(here)
library(magrittr)
library(futile.logger)

source(here::here("transformer/utils/rollbar.R"))

help <- "
Usage:
Rscript export_dados_bd.R <anos> <filtro>
<anos> pode ser um ano (2017) ou múltiplos anos separados por vírgula (2017,2018,2019)
<filtro> pode ser merenda ou covid
<administracoes> pode ser um estado ('RS') ou múltiplos estados separados por vírgula ('PE', 'RS')
Exemplos:
Rscript export_dados_bd.R 2019 merenda RS,PE
Rscript export_dados_bd.R 2018,2019,2020 merenda RS,PE
"

args <- commandArgs(trailingOnly = TRUE)
min_num_args <- 3
if (length(args) < min_num_args) {
  stop(paste("Wrong number of arguments!", help, sep = "\n"))
}

anos <- unlist(strsplit(args[1], split=","))
# anos = c(2020)
filtro <- args[2]
# filtro <- "merenda"
administracoes <- unlist(strsplit(args[3], split=","))
# administracoes <- c("RS", "PE")

source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/constants.R"))

source(here::here("transformer/processor/aggregator/aggregator_compras.R"))
source(here::here("transformer/processor/aggregator/aggregator_contratos.R"))
source(here::here("transformer/processor/aggregator/aggregator_documentos_licitacao.R"))
source(here::here("transformer/processor/aggregator/aggregator_fornecedores.R"))
source(here::here("transformer/processor/aggregator/aggregator_itens_contrato.R"))
source(here::here("transformer/processor/aggregator/aggregator_itens_licitacao.R"))
source(here::here("transformer/processor/aggregator/aggregator_licitacoes.R"))
source(here::here("transformer/processor/aggregator/aggregator_licitantes.R"))
source(here::here("transformer/processor/aggregator/aggregator_municipios.R"))
source(here::here("transformer/processor/aggregator/aggregator_orgaos.R"))


## Assume que os dados foram baixados usando o módulo do crawler de dados (presente no diretório crawler
## na raiz desse repositório)

# Processamento dos dados
flog.info("#### Iniciando processamento...")

#--------------------------------- Processamento dos dados agregados -------------------------------------------

info_orgaos <- aggregator_orgaos(anos, filtro, administracoes)
gc()

info_municipios_monitorados <- aggregator_municipios(info_orgaos)
gc()

info_licitacoes <- aggregator_licitacoes(anos, filtro, administracoes)
gc()

info_licitantes <- aggregator_licitantes(anos, administracoes, info_licitacoes)
gc()

info_contratos <- aggregator_contratos(anos, administracoes, info_licitacoes)
gc()

info_item_licitacao <- aggregator_itens_licitacao(anos, administracoes, info_licitacoes)
gc()

info_documento_licitacao <- aggregator_documentos_licitacao(anos, administracoes, info_licitacoes)
gc()

info_compras <- aggregator_compras(anos, filtro, administracoes, info_licitacoes, info_orgaos)
gc()

info_contratos <- info_contratos %>%
  dplyr::bind_rows(info_compras)

if (nrow(info_contratos) > 0) {
  info_contratos <- info_contratos %>% 
    dplyr::mutate(language = 'portuguese') %>% 
    distinct(id_contrato, .keep_all = TRUE)
} else {
  flog.warn("Nenhum dado de contrato foi processado!")
}

info_item_contrato <- aggregator_itens_contrato(anos, filtro, administracoes, info_licitacoes, info_contratos, info_orgaos, info_item_licitacao)
gc()

contrato <- info_item_contrato %>% filter(codigo_empenho == '160146000012021NE000096')
flog.warn("==========================================")
flog.warn(contrato)
flog.warn("==========================================")

info_fornecedores_contratos <- aggregator_fornecedores(anos, administracoes, info_contratos)
gc()

#----------------------------------------------- # Escrita dos dados -------------------------------------------------
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
