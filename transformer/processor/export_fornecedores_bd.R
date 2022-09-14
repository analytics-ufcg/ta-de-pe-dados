library(tidyverse)
library(magrittr)
library(futile.logger)

source(here::here("transformer/utils/rollbar.R"))

help <- "
Usage:
Rscript export_fornecedores_bd.R <anos>
<anos> pode ser um ano (2017) ou múltiplos anos separados por vírgula (2017,2018,2019)
"

args <- commandArgs(trailingOnly = TRUE)
min_num_args <- 2
if (length(args) < min_num_args) {
  stop(paste("Wrong number of arguments!", help, sep = "\n"))
}

anos <- unlist(strsplit(args[1], split=","))
# anos = c(2018, 2019, 2020, 2021)
administracoes <- unlist(strsplit(args[2], split=","))

source(here::here("transformer/adapter/estados/RS/contratos/adaptador_contratos_rs.R"))
source(here::here("transformer/adapter/estados/RS/contratos/adaptador_fornecedores_contratos_rs.R"))
source(here::here("transformer/processor/estados/PE/contratos/processador_contratos_pe.R"))
source(here::here("transformer/processor/estados/PE/contratos/processador_fornecedores_contratos_pe.R"))
source(here::here("transformer/processor/estados/Federal/contratos/processador_compras_federal.R"))
source(here::here("transformer/processor/estados/Federal/contratos/processador_fornecedores_contratos_federal.R"))
source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/utils/join_utils.R"))

contratos_processados_df <- read_contratos_processados()

if ("RS" %in% administracoes) {
  fornecedores_contratos_rs <- tryCatch({
    flog.info("#### Atualizando dados de fornecedores do RS...")
    
    compras_rs <- contratos_processados_df %>% 
      filter(sigla_estado == "RS")
    contratos_rs <- import_contratos(anos) %>%
      adapta_info_contratos()
    
    import_fornecedores(anos) %>% 
      adapta_info_fornecedores(contratos_rs, compras_rs) %>% 
      add_info_estado(sigla = "RS", id_estado = "43")
  }, error = function(e) {
    flog.error("Ocorreu um erro ao processar os dados de fornecedores do RS")
    flog.error(e)
    return(tibble())
  })
} else {
  fornecedores_contratos_rs <- tibble()
}

if ("PE" %in% administracoes) {
  fornecedores_contratos_pe <- tryCatch({
    flog.info("#### Atualizando dados de fornecedores do PE...")
    contratos_pe <- processa_contratos_pe()
    
    processa_fornecedores_contratos_pe(contratos_pe)
  }, error = function(e) {
    flog.error("Ocorreu um erro ao processar os dados de fornecedores do PE")
    flog.error(e)
    return(tibble())
  })
} else {
  fornecedores_contratos_pe <- tibble()
}

if ("BR" %in% administracoes) {
  fornecedores_contratos_federais <- tryCatch({
    flog.info("#### Atualizando dados de fornecedores do Governo Federal...")
    compras_federais <- processa_compras_federal()
    
    processa_fornecedores_contratos_federal(compras_federais)
  }, error = function(e) {
    flog.error("Ocorreu um erro ao processar os dados de fornecedores do Governo Federal")
    flog.error(e)
    return(tibble())
  })
} else {
  fornecedores_contratos_federais <- tibble()
}

if (nrow(fornecedores_contratos_rs) == 0 && nrow(fornecedores_contratos_pe) == 0 && nrow(fornecedores_contratos_federais) == 0) {
  flog.warn("Nenhum dado de fornecedores para agregar")
  return(tibble())
}

flog.info("#### Agregando dados de fornecedores")
info_fornecedores_contratos <- bind_rows(fornecedores_contratos_rs,
                                         fornecedores_contratos_pe,
                                         fornecedores_contratos_federais) %>% 
  join_contratos_e_fornecedores(contratos_processados_df %>% 
                                  dplyr::select(nr_documento_contratado)) %>% 
  dplyr::distinct(nr_documento, id_estado, .keep_all = TRUE) %>% 
  dplyr::group_by(nr_documento) %>% 
  dplyr::mutate(total_de_contratos = sum(total_de_contratos, na.rm = T),
                data_primeiro_contrato = min(data_primeiro_contrato, na.rm = T)) %>% 
  dplyr::distinct(nr_documento, .keep_all = TRUE) %>%
  dplyr::select(nr_documento, id_estado, nm_pessoa, tp_pessoa, total_de_contratos, data_primeiro_contrato)

readr::write_csv(info_fornecedores_contratos, here::here("data/bd/info_fornecedores_contrato.csv"))

flog.info("Concluído!")
