join_licitacao_e_tipo <- function(licitacao_df, tipo_licitacao_df) {
  licitacao_df %>% 
    dplyr::left_join(tipo_licitacao_df, by = c("tp_licitacao"))
}

join_licitacoes_e_itens <- function(itens_df, licitacoes_df) {
  licitacoes_df %<>% dplyr::select("id_orgao", "ano_licitacao", "cd_tipo_modalidade", "nr_licitacao", "licitacao_id")
  itens_df %>% 
    dplyr::inner_join(licitacoes_df)
}

join_licitante_e_licitacao <- function(licitante_df, licitacao_df) {
  licitante_df %>% 
    dplyr::right_join(licitacao_df, by = c("id_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade"))
}