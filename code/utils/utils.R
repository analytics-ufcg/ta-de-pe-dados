#' Gera um identificador único para cada registro do dataframe
#' @param df Dataframe sem identificador único
#' @param ano Inteiro com o ano para uso na criação do identificador
#' @param constante Identificador da tabela
#' @param id Nome da coluna do identificador
#' @return Dataframe com identificador único
generate_id <- function(df, ano, constante, id) {
  df[, id] <- paste0(constante, ano, seq.int(nrow(df)))
  df
}
