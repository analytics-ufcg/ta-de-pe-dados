library(magrittr)
source(here::here('code/licitacoes/processa_licitacoes.R'))
source(here::here('code/utils/utils.R'))
source(here::here('code/utils/constants.R'))

help <- "
Usage:
Rscript preprocess_tnm_licitacoes.R <ano> <export_path>
"

args <- commandArgs(trailingOnly = TRUE)
min_num_args <- 2
if (length(args) < min_num_args) {
  stop(paste("Wrong number of arguments!", help, sep = "\n"))
}

ano <- args[1]
export_path <- args[2]

licitacoes <- import_licitacoes_por_ano(ano) %>% generate_id(ano, TABELA_LICITACAO)

readr::write_csv(licitacoes, paste0(export_path, "/licitacoes/", ano, "/licitacao.csv"))
