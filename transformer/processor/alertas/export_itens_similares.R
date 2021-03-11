library(magrittr)

source(here::here("transformer/utils/bd_constants.R"))
source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/constants.R"))
.HELP <- "Rscript fetch_dados_ta_na_mesa.R"

ta_na_mesa_db <- NULL

#' @title Busca os itens similares do banco do ta-na-mesa
#' @param ta_na_mesa_con Conexão com o Banco de Dados
#' @return Dataframe contendo informações sobre os itens similares
#' @rdname fetch_itens_similares
#' @examples
#' itens_similares <- fetch_itens_similares(ta_na_mesa_con)
fetch_itens_similares<- function(ta_na_mesa_con) {
  itens_similares <- tibble::tibble()
  tryCatch({
    itens_similares <- DBI::dbGetQuery(ta_na_mesa_con, "SELECT * FROM itens_unicos_similaridade;")
    cat("-  Tabela 'itens_unicos_similaridade' do Ta-na-mesa recuperada com sucesso!")
  },
  error = function(e) stop(paste0("Erro ao buscar 'itens_unicos_similaridade' no banco Ta-na-mesa (PostgreSQL): \n",
                                  "  - Verifique se o processamento de itens similares foi realizado.\n \n", e))
  )
  
  return(itens_similares)
}

tryCatch({ta_na_mesa_db <- DBI::dbConnect(RPostgres::Postgres(),
                                    dbname = POSTGRES_DB,
                                    host = POSTGRES_HOST,
                                    port = POSTGRES_PORT,
                                    user = POSTGRES_USER,
                                    password = POSTGRES_PASSWORD)
}, error = function(e) print(paste0("Erro ao tentar se conectar ao banco do Ta-na-Mesa (Postgres): ", e)))

itens_unicos_similaridade_rs <- fetch_itens_similares(ta_na_mesa_db)

readr::write_csv(itens_unicos_similaridade_rs, here::here("data/bd/itens_similares.csv"))
