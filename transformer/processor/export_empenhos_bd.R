library(here)
library(magrittr)

help <- "
Usage:
Rscript export_empenhos_bd.R
"

host <- Sys.getenv("POSTGRES_HOST")
user <- Sys.getenv("POSTGRES_USER")
database <- Sys.getenv("POSTGRES_DB")
port <- Sys.getenv("POSTGRES_PORT")
password <- Sys.getenv("POSTGRES_PASSWORD")

message(paste0("Host: ", host))
message(paste0("User: ", user))

source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/constants.R"))
source(here::here("transformer/adapter/estados/RS/empenhos/adaptador_empenhos_rs.R"))

con <- DBI::dbConnect(RPostgres::Postgres(),
                      dbname = database, 
                      host = host, 
                      port = port,
                      user = user,
                      password = 'secret')

res <- DBI::dbGetQuery(con, "SELECT licitacao.id_licitacao, empenho_raw.* FROM licitacao INNER JOIN empenho_raw ON 
                   licitacao.id_orgao = empenho_raw.cd_orgao AND 
                   licitacao.nr_licitacao = empenho_raw.nr_licitacao AND
                   licitacao.cd_tipo_modalidade = empenho_raw.mod_licitacao AND
                   licitacao.ano_licitacao = empenho_raw.ano_licitacao;")

contratos_df <- read_contratos_processados()

info_empenhos <- res %>% 
  adapta_info_empenhos() %>% 
  join_empenhos_e_contratos(contratos_df) %>% 
  generate_id(TABELA_EMPENHO, E_ID) %>% 
  dplyr::select(id_empenho, id_licitacao, id_orgao, id_contrato, dplyr::everything()) %>% 
  adapta_id_contrato_empenhos()

readr::write_csv(info_empenhos, here("data/bd/info_empenhos.csv"))
