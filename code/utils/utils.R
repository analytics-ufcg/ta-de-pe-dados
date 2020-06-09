#' Gera um identificador único para cada registro do dataframe
#' @param df Dataframe sem identificador único
#' @param constante Identificador da tabela
#' @param id Nome da coluna do identificador
#' @return Dataframe com identificador único
generate_id <- function(df, constante, id) {
  df[, id] <- paste0(constante, df$ano_licitacao, seq.int(nrow(df)))
  return(df)
}

#' Gera um identificador único para cada registro do dataframe. 
#' Usa o algoritmo md5 para gerar um hash a partir da concatenação das colunas
#' que devem ser chave primária do dataframe passado como parâmetro.
#' @param df Dataframe sem identificador único
#' @param colunas array com o nome das colunas que são chave primária do dataframe
#' @param id_coluna Nome da coluna do identificador
#' @return Dataframe com identificador único
generate_hash_id <- function(df, colunas, id_coluna) {
  df <- df %>% 
    mutate(concat_chave_primaria = do.call(paste, lapply(colunas, function(x) get(x)))) %>% 
    rowwise() %>% 
    mutate(!!id_coluna := digest::digest(concat_chave_primaria, algo="md5", serialize=F)) %>% 
    ungroup() %>% 
    select(-concat_chave_primaria)
  
  return(df)
}
