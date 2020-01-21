join_licitacao_e_tipo <- function(licitacao_df, tipo_licitacao_df) {
  licitacao_df %>% 
    dplyr::left_join(tipo_licitacao_df, by = c("tp_licitacao"))
}

join_licitante_e_licitacao <- function(licitante_df, licitacao_df) {
  licitante_df %>% 
    dplyr::right_join(licitacao_df, by = c("id_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade"))
}