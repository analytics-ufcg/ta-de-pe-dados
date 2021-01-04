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