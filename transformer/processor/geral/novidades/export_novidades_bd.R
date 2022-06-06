library(tidyverse)
library(magrittr)
library(futile.logger)

source(here::here("transformer/utils/rollbar.R"))

help <- "
Usage:
Rscript export_novidades_bd.R
"
source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/constants.R"))
source(here::here("transformer/processor/geral/novidades/processa_novidades.R"))

flog.info("Processando novidades")

tipos_novidades <- create_tipo_novidades()

orgao_municipio <- read_orgaos_processados() %>% dplyr::select(id_orgao, nome_municipio)

licitacoes <- read_licitacoes_processadas() %>% join_licitacao_e_orgao(orgao_municipio) %>% gather_licitacoes() %>% 
  transforma_licitacao_em_novidades()

flog.info(str_glue("{licitacoes %>% nrow()} novidades de licitações geradas!"))

empenhos <- tryCatch({
  read_empenhos_processados() %>% join_empenho_e_orgao(orgao_municipio) %>% gather_empenhos() %>% 
  transforma_empenhos_em_novidades()
}, error = function(e) {
  flog.error("Ocorreu um erro ao processar as novidades de empenho")
  flog.error(e)
  return(tibble())
})

flog.info(str_glue("{empenhos %>% nrow()} novidades de empenhos geradas!"))

contratos <- read_contratos_processados() %>% join_contrato_e_orgao(orgao_municipio) %>% gather_contratos() %>% 
  transforma_contrato_em_novidades()

flog.info(str_glue("{contratos %>% nrow()} novidades de contratos geradas!"))

flog.info("Gerando tabela de novidades")
novidades <- dplyr::bind_rows(licitacoes, contratos, empenhos) %>% 
  generate_hash_id(c("id_tipo", "id_licitacao", "id_original"), NOVIDADE_ID) %>% 
  dplyr::select(id_novidade, id_tipo, id_licitacao, data, id_original, nome_municipio, texto_novidade, id_contrato)

readr::write_csv(tipos_novidades, here::here("data/bd/tipo_novidade.csv"))
readr::write_csv(novidades, here::here("data/bd/novidade.csv"))
flog.info("Concluído!")
