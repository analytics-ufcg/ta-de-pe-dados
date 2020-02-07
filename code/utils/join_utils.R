join_licitacao_e_tipo <- function(licitacao_df, tipo_licitacao_df) {
  licitacao_df %>% 
    dplyr::left_join(tipo_licitacao_df, by = c("tp_licitacao"))
}

join_licitacoes_e_itens <- function(itens_df, licitacoes_df) {
  licitacoes_df %<>% dplyr::select("id_orgao", "ano_licitacao", "cd_tipo_modalidade", "nr_licitacao", "id_licitacao")
  itens_df %>% 
    dplyr::inner_join(licitacoes_df)
}

join_contratos_e_itens <- function(itens_contrato_df, contratos_df) {
  itens_contrato_df %>% 
    dplyr::right_join(contratos_df, 
               by = c("id_orgao", "nr_licitacao", "cd_tipo_modalidade",
                     "ano_licitacao", "nr_contrato", "ano_contrato", 
                     "tp_instrumento_contrato"))
}

join_contrato_e_licitacao <- function(contrato_df, licitacao_df) {
  contrato_df %>%  
    dplyr::inner_join(licitacao_df, by = c("id_orgao", "nr_licitacao", 
                                           "ano_licitacao", "cd_tipo_modalidade"))
}

join_contrato_e_instrumento <- function(contratos_df, tipo_instrumento_contrato_df) {
  contratos_df %>% 
    dplyr::left_join(tipo_instrumento_contrato_df, by = c("tp_instrumento_contrato"))
}

join_alteracoes_contrato_e_tipo <- function(alteracoes_contrato_df, tipo_operacao_alteracao) {
  alteracoes_contrato_df %>% 
    dplyr::left_join(tipo_operacao_alteracao, by = c("cd_tipo_operacao"))
}

join_alteracoes_contrato_e_contrato <- function(alteracoes_contrato_df, contrato_df) {
  alteracoes_contrato_df %>% 
    dplyr::inner_join(contrato_df %>% dplyr::select(id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade,
                                                    nr_contrato, ano_contrato, tp_instrumento_contrato,
                                                    id_contrato), 
                      by = c("id_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade", 
                                          "nr_contrato", "ano_contrato", "tp_instrumento_contrato"))
}

join_licitante_e_licitacao <- function(licitante_df, licitacao_df) {
  licitante_df %>% 
    dplyr::inner_join(licitacao_df, by = c("id_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade"))
}
