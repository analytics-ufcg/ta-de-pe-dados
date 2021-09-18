library(tidyverse)
library(here)
library(magrittr)
library(futile.logger)

#' @title Recupera dados de itens de empenhos federais filtrados
#' @description Acessa o banco de dados local de processamento e filtra os dados de itens de empenhos federais com base 
#' no código de ação. A lista de código de ações usada aqui se refere apenas a ações relacionas a pandemia da 
#' COVID-19
#' É preciso
#' @param host Host do banco de dados
#' @param user User do banco de dados
#' @param database Nome do database
#' @param port Porta do banco de dados
#' @param password Senha para acesso ao banco de dados
#' @return Dados de empenhos federais filtrados
#' @example empenhos_filtrados <- read_itens_empenhos_federais_covid('postgres', 'postgres', 'tanamesa', 5432, 'secret')
read_itens_empenhos_federais_covid <- function(host, user, database, port, password) {
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
      "SELECT * FROM itens_empenhos_raw_federais as item ", 
      "JOIN empenhos_raw_federais as emp ",
      "ON item.codigo_empenho = emp.codigo ",
      "WHERE codigo_acao IN ",
      "('00S4', '00S5', '00S7', '00S8', '00S9', '00SF', '00SH', '21C0', '21C1', '21C2', '00SI', '21C0')"
    )
  )

  ## Filtro para remover órgãos fora do contexto do Governo Federal
  filtered_res <- res %>% 
    filter(as.numeric(codigo_orgao_superior) %% 1000 == 0, 
           as.numeric(codigo_orgao_superior) > 2e4, as.numeric(codigo_orgao_superior) < 9e4)
  
  return(filtered_res)
}
