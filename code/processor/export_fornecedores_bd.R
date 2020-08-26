library(magrittr)

help <- "
Usage:
Rscript export_fornecedores_bd.R
"
source(here::here("code/contratos/processa_fornecedores.R"))
source(here::here("code/utils/read_utils.R"))

empenhos_df <- read_empenhos_processados()
compras_df <- read_contratos_processados()

compras_atualizadas <- processa_fornecedores_compras(empenhos_df, compras_df)

print("Atualizando dados de fornecedores...")
contratos <- import_contratos(anos) %>% 
  processa_info_contratos()

info_fornecedores_contratos <- import_fornecedores(anos) %>% 
  processa_info_fornecedores(contratos) %>% 
  join_contratos_e_fornecedores(compras_atualizadas %>% 
                                  dplyr::select(nr_documento_contratado)) %>% 
  dplyr::distinct(nr_documento, .keep_all = TRUE) %>% 
  dplyr::select(nr_documento, nm_pessoa, tp_pessoa, total_de_contratos, data_primeiro_contrato)

readr::write_csv(compras_atualizadas, here("data/bd/info_contrato.csv"))
readr::write_csv(info_fornecedores_contratos, here("data/bd/info_fornecedores_contrato.csv"))

print("Concluído!")
