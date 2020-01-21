join_licitacao_e_tipo <- function(licitacao_df, tipo_licitacao_df) {
  licitacao_df %>% 
    left_join(tipo_licitacao_df, by = c("tp_licitacao"))
}

join_contrato_e_licitacao <- function(contrato_df, licitacao_df) {
  contrato_df %>%  
    right_join(licitacao_df, by = c("id_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade"))
}

join_contrato_e_instrumento <- function(contratos_df, tipo_instrumento_contrato_df) {
  contratos_df %>% 
    left_join(tipo_instrumento_contrato_df, by = c("tp_instrumento_contrato"))
}
