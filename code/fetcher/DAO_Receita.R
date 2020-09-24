#' @title Busca dados cadastrais dos fornecedores do RS no Banco da Receita Federal
#' @param receita_con Conexão com o Banco de Dados
#' @param cnpjs_rs CNPJs dos fornecedores
#' @return Dataframe contendo informações sobre os  dados cadastrais
#' @rdname fetch_dados_cadastrais
#' @examples
#' dados_cadastrais <- fetch_dados_cadastrais(receita_con, cnpjs_rs)
fetch_dados_cadastrais <- function(receita_con, cnpjs_rs) {
  dados <- tibble::tibble()

  dados <- tibble::tibble()
  tryCatch({
    dados <- cnpjs_rs %>%
      purrr::map_df(~DBI::dbGetQuery(receita_con, paste0("SELECT * FROM cnpj_dados_cadastrais_pj where cnpj=\'", .x, "\'")))
  },
  error = function(e) print(paste0("Erro ao buscar dados cadastrais no Banco Receita (Postgres): ", e))
  )
  
  return(dados)
}

#' @title Busca socios dos fornecedores do RS no Banco da Receita Federal
#' @param receita_con Conexão com o Banco de Dados
#' @param cnpjs_rs CNPJs dos fornecedores
#' @return Dataframe contendo informações sobre os socios dos fornecedores
#' @rdname fetch_socios
#' @examples
#' socios <- fetch_socios(receita_con, cnpjs_rs)
fetch_socios <- function(receita_con, cnpjs_rs) {
  socios <- tibble::tibble()
  tryCatch({
    socios <- cnpjs_rs %>%
      purrr::map_df(~DBI::dbGetQuery(receita_con, paste0("SELECT * FROM cnpj_dados_socios_pj where cnpj=\'", .x, "\'")))
  },
  error = function(e) print(paste0("Erro ao buscar dados cadastrais no Banco Receita (Postgres): ", e))
  )
  
  return(socios)
}