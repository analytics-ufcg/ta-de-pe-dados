library(tidyverse)
library(magrittr)

help <- "
Usage:
Rscript export_fornecedores_bd.R <anos>
<anos> pode ser um ano (2017) ou múltiplos anos separados por vírgula (2017,2018,2019)
"

args <- commandArgs(trailingOnly = TRUE)
min_num_args <- 1
if (length(args) < min_num_args) {
  stop(paste("Wrong number of arguments!", help, sep = "\n"))
}

anos <- unlist(strsplit(args[1], split=","))
# anos = c(2018, 2019, 2020)

source(here::here("transformer/adapter/estados/RS/contratos/adaptador_contratos_rs.R"))
source(here::here("transformer/adapter/estados/RS/contratos/adaptador_fornecedores_contratos_rs.R"))
source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/utils/join_utils.R"))

compras_df <- read_contratos_processados()

print("Atualizando dados de fornecedores...")
contratos <- import_contratos(anos) %>% 
  processa_info_contratos()

info_fornecedores_contratos <- import_fornecedores(anos) %>% 
  processa_info_fornecedores(contratos, compras_df) %>% 
  join_contratos_e_fornecedores(compras_df %>% 
                                  dplyr::select(nr_documento_contratado)) %>% 
  dplyr::distinct(nr_documento, .keep_all = TRUE) %>% 
  dplyr::select(nr_documento, nm_pessoa, tp_pessoa, total_de_contratos, data_primeiro_contrato)


readr::write_csv(info_fornecedores_contratos, here::here("data/bd/info_fornecedores_contrato.csv"))

print("Concluído!")
