join_licitacao_e_tipo <- function(licitacao_df, tipo_licitacao_df) {
  licitacao_df %>% 
    left_join(tipo_licitacao_df, by = c("tp_licitacao"))
}