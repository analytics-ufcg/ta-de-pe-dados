
library(tidyverse)
library(here)
library(magrittr)

help <- "
Usage:
Rscript export_empenhos_federais.R
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

con <- DBI::dbConnect(RPostgres::Postgres(),
                      dbname = database, 
                      host = host, 
                      port = port,
                      user = user,
                      password = 'secret')

res <- DBI::dbGetQuery(con, "SELECT * FROM empenhos_raw_federais WHERE acao NOT IN ('00S4', '00S5', '00S7', '00S8', '00S9', '00SF', '00SH', '21C0', '21C1', '21C2', '00SI', '21C0')")

return(res)