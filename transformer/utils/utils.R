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
    dplyr::mutate(concat_chave_primaria = do.call(paste, lapply(colunas, function(x) get(x)))) %>% 
    dplyr::rowwise() %>% 
    dplyr::mutate(!!id_coluna := digest::digest(concat_chave_primaria, algo="md5", serialize=F)) %>% 
    dplyr::ungroup() %>% 
    dplyr::select(-concat_chave_primaria)
  
  return(df)
}

#' Remove duplicação no nome das colunas dos documentos de vencedores e fornecedores
#' @param df Dataframe com duplicação no nome das colunas
#' @return Dataframe com nome correto para as colunas
rename_duplicate_columns <- function(df) {
  names(df)[names(df) == 'TP_DOCUMENTO'] <- 'TP_DOCUMENTO_VENCEDOR'
  names(df)[names(df) == 'NR_DOCUMENTO'] <- 'NR_DOCUMENTO_VENCEDOR'
  names(df)[names(df) == 'TP_DOCUMENTO_1'] <- 'TP_DOCUMENTO_FORNECEDOR'
  names(df)[names(df) == 'NR_DOCUMENTO_1'] <- 'NR_DOCUMENTO_FORNECEDOR'
  df
}

#' Adiciona colunas com informações do estado
#' @param df Dataframe para adição de colunas
#' @return Dataframe com informações do estado
add_info_estado <- function(df, sigla_estado, id_estado) {
  df %<>% dplyr::mutate(sigla_estado = sigla_estado, id_estado = id_estado)
}
