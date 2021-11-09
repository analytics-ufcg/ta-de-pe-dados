library(dplyr)
library(futile.logger)
library(tidyverse)


#' @param host Host do banco de dados
#' @param user User do banco de dados
#' @param database Nome do database
#' @param port Porta do banco de dados
#' @param password Senha para acesso ao banco de dados
#' @return Dados de histórico de itens de empenhos federais
#' @example historico_itens <- read_historico_itens_federais('postgres', 'postgres', 'tanamesa', 5432, 'secret')
read_historico_itens_federais <- function(host, user, database, port, password) {
  flog.info(paste0("Host: ", host))
  flog.info(paste0("User: ", user))
  
  con <- DBI::dbConnect(RPostgres::Postgres(),
                        dbname = database, 
                        host = host, 
                        port = port,
                        user = user,
                        password = 'secret')
  
  res <- DBI::dbGetQuery(
    con,
    str_glue(
      "SELECT * FROM itens_historico_raw_federais ",
    )
  )
  
  return(res)
}
