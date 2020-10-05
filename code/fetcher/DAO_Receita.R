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
    message("Informações cadastrais")
    dados <- cnpjs_rs %>%
      purrr::map_df(function(cnpj) {
        cat(paste0("Recuperando dados cadastrais para o CNPJ: ", cnpj, "\r"))
        DBI::dbGetQuery(
          receita_con,
          paste0(
            "SELECT * FROM cnpj_dados_cadastrais_pj where cnpj=\'",
            cnpj,
            "\'"
          )
        )
      })
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
  message("\nInformações de sócios")
  tryCatch({
    socios <- cnpjs_rs %>%
      purrr::map_df(function(cnpj) {
        cat(paste0("Recuperando dados de sócios para o CNPJ: ", cnpj, "\r"))
        DBI::dbGetQuery(receita_con,
                        paste0("SELECT * FROM cnpj_dados_socios_pj where cnpj=\'", cnpj, "\'"))
      })
  },
  error = function(e) print(paste0("Erro ao buscar dados de sócios no Banco Receita (Postgres): ", e))
  )
  
  return(socios)
}

#' @title Busca os CNAE's dos fornecedores do RS no Banco da Receita Federal
#' @param receita_con Conexão com o Banco de Dados
#' @param cnpjs_rs CNPJs dos fornecedores
#' @return Dataframe contendo informações sobre os CNAEs secundários dos fornecedores
#' @rdname fetch_cnaes_secundarios
#' @examples
#' cnaes <- fetch_cnaes_secundarios(receita_con, cnpjs_rs)
fetch_cnaes_secundarios <- function(receita_con, cnpjs_rs) {
  cnaes <- tibble::tibble()
  message("\nInformações de CNAES secundários")
  tryCatch({
    cnaes <- cnpjs_rs %>%
      purrr::map_df(function(cnpj) {
        cat(paste0("Recuperando dados de cnaes para o CNPJ: ", cnpj, "\r"))
        DBI::dbGetQuery(receita_con,
                        paste0("SELECT * FROM cnpj_dados_cnae_secundario_pj where cnpj=\'", cnpj, "\'"))
      })
  },
  error = function(e) print(paste0("Erro ao buscar dados de cnaes no Banco Receita (Postgres): ", e))
  )
  
  return(cnaes)
}

#' @title Busca informações sobre os CNAE's no Banco da Receita Federal
#' @param receita_con Conexão com o Banco de Dados
#' @return Dataframe contendo informações sobre os CNAEs
#' @rdname fetch_cnaes_info
#' @examples
#' cnaes <- fetch_cnaes_info(receita_con)
fetch_cnaes_info <- function(receita_con) {
  cnaes <- tibble::tibble()
  tryCatch({
    cat("\nRecuperando informações sobre os cnaes")
    cnaes <- DBI::dbGetQuery(receita_con, "SELECT * FROM tab_cnae")
  }, 
  error = function(e) print(paste0("Erro ao buscar dados sobre os cnaes no Banco Receita (Postgres): ", e))
  )
  
  return(cnaes)
}
