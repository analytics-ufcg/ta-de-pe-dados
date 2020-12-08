library(magrittr)

source(here::here("code/fetcher/setup/constants.R"))
source(here::here("code/fetcher/DAO_ta_na_mesa.R"))
source(here::here("code/utils/utils.R"))
source(here::here("code/utils/constants.R"))
.HELP <- "Rscript fetch_dados_ta_na_mesa.R"

ta_na_mesa_db <- NULL

tryCatch({ta_na_mesa_db <- DBI::dbConnect(RPostgres::Postgres(),
                                    dbname = POSTGRES_DB,
                                    host = POSTGRES_HOST,
                                    port = POSTGRES_PORT,
                                    user = POSTGRES_USER,
                                    password = POSTGRES_PASSWORD)
}, error = function(e) print(paste0("Erro ao tentar se conectar ao banco do Ta-na-Mesa (Postgres): ", e)))

itens_unicos_similaridade_rs <- fetch_itens_similares(ta_na_mesa_db)

readr::write_csv(itens_unicos_similaridade_rs, here::here("data/bd/itens_similares.csv"))
