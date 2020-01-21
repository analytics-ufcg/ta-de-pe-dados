join_licitacao_e_tipo <- function(licitacao_df, tipo_licitacao_df) {
  licitacao_df %>% 
    dplyr::left_join(tipo_licitacao_df, by = c("tp_licitacao"))
}

join_alteracoes_contrato_e_tipo <- function(alteracoes_contrato_df, tipo_operacao_alteracao) {
  alteracoes_contrato_df %>% 
    dplyr::left_join(tipo_operacao_alteracao, by = c("cd_tipo_operacao"))
}