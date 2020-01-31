library(here)
library(magrittr)

help <- "
Usage:
Rscript export_empenhos_bd.R
"

source(here::here("code/utils/utils.R"))
source(here::here("code/utils/constants.R"))
source(here::here("code/empenhos/processa_empenhos.R"))


con <- DBI::dbConnect(RPostgres::Postgres(),
                      dbname = 'tanamesa', 
                      host = 'localhost', 
                      port = 7655,
                      user = 'postgres',
                      password = 'secret')

res <- DBI::dbGetQuery(con, "SELECT licitacao.id_licitacao, empenho_raw.* FROM licitacao INNER JOIN empenho_raw ON 
                   licitacao.id_orgao = empenho_raw.cd_orgao AND 
                   licitacao.nr_licitacao = empenho_raw.nr_licitacao AND
                   licitacao.cd_tipo_modalidade = empenho_raw.mod_licitacao AND
                   licitacao.ano_licitacao = empenho_raw.ano_licitacao;")

info_empenhos <- res %>% 
  processa_info_empenhos() %>% 
  generate_id(TABELA_EMPENHO, E_ID) %>% 
  dplyr::select(id_empenho, id_licitacao, id_orgao, dplyr::everything())

readr::write_csv(info_empenhos, here("data/bd/info_empenhos.csv"))
