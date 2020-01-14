library(magrittr)
source(here::here('code/licitacoes/processa_itens.R'))

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

itens <- import_itens_licitacao_por_ano(ano) %>% rename_duplicate_columns() %>% generate_id(ano)

readr::write_csv(itens, paste0(export_path, "/licitacoes/", ano, "/item.csv"))
