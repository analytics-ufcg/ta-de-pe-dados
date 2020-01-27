#' Gera um identificador único para cada registro do dataframe
#' @param df Dataframe sem identificador único
#' @param constante Identificador da tabela
#' @param id Nome da coluna do identificador
#' @return Dataframe com identificador único
generate_id <- function(df, constante, id) {
  df[, id] <- paste0(constante, df$ano_licitacao, seq.int(nrow(df)))
  df
}
