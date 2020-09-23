library(magrittr)

source(here::here("code/fetcher/setup/constants.R"))
source(here::here("code/fetcher/DAO_Receita.R"))


.HELP <- "Rscript fetch_dados_receita.R"

receita <- NULL

tryCatch({receita <- DBI::dbConnect(RPostgres::Postgres(),
                                    dbname = RECEITA_DB,
                                    host = RECEITA_HOST,
                                    port = RECEITA_PORT,
                                    user = RECEITA_USER,
                                    password = RECEITA_PASSWORD)
}, error = function(e) print(paste0("Erro ao tentar se conectar ao Banco Receita (Postgres): ", e)))

cnpjs_rs <- readr::read_csv(here::here("data/bd/info_fornecedores_contrato.csv"))$nr_documento

dados_cnpjs_rs <- fetch_dados_cadastrais(receita, cnpjs_rs) 
socios_rs <- fetch_socios(receita, cnpjs_rs)


readr::write_csv(dados_cnpjs_rs, here::here("data/bd/dados_cadastrais.csv"))
readr::write_csv(socios_rs, here::here("data/bd/socios.csv"))

