join_licitacao_e_tipo <- function(licitacao_df, tipo_licitacao_df) {
  licitacao_df %>% 
    dplyr::left_join(tipo_licitacao_df, by = c("tp_licitacao"))
}

join_licitacao_e_tipo_modalidade <- function(licitacao_df, tipo_modalidade_licitacao_df) {
  licitacao_df %>% 
    dplyr::left_join(tipo_modalidade_licitacao_df, by = c("cd_tipo_modalidade"))
}

join_licitacoes_e_itens <- function(itens_df, licitacoes_df) {
  licitacoes_df %<>% dplyr::select("cd_orgao", "ano_licitacao", "cd_tipo_modalidade", "nr_licitacao", "id_licitacao")
  itens_df %<>% 
    dplyr::inner_join(licitacoes_df)
}

join_contratos_e_itens <- function(itens_contrato_df, contratos_df) {
  
  contratos_rs_pe <- contratos_df %>% filter(id_estado %in% c("43","26"))
  itens_rs_pe <- itens_contrato_df %>% filter(id_estado %in% c("43","26"))
  
  if(nrow(itens_rs_pe) > 0) {
    itens_rs_pe <- itens_rs_pe %>% 
      dplyr::inner_join(contratos_rs_pe,
                        by = c("cd_orgao", "nr_licitacao", "cd_tipo_modalidade",
                               "ano_licitacao", "nr_contrato", "ano_contrato", 
                               "codigo_contrato", "tp_instrumento_contrato", "id_estado"))
  }
  
  contratos_br <- contratos_df %>% filter(id_estado == "99")
  itens_br <- itens_contrato_df %>% filter(id_estado == "99")
  
  if ("ano_licitacao" %in% names(itens_br)) {
    itens_br <- itens_br %>% dplyr::select(-ano_licitacao)
  }
  
  if ("cd_tipo_modalidade" %in% names(itens_br)) {
    itens_br <- itens_br %>% dplyr::select(-cd_tipo_modalidade)
  }
  
  if(nrow(itens_br) > 0) {
    itens_br <- itens_br %>% 
      dplyr::inner_join(
        contratos_br,
        by = c(
          "codigo_contrato",
          "cd_orgao",
          "nr_licitacao",
          "nr_contrato",
          "ano_contrato",
          "tp_instrumento_contrato",
          "id_estado"
        )
      )
  }
  
  itens <- bind_rows(itens_rs_pe, itens_br)
  return(itens)
}

join_contrato_e_licitacao <- function(contrato_df, licitacao_df) {
  
  contratos_pe <- contrato_df %>% filter(id_estado == "26")
  
  if ("ano_licitacao" %in% names(contratos_pe) && 
      "cd_tipo_modalidade" %in% names(contratos_pe)) {
    contratos_pe <- contratos_pe %>% 
      dplyr::select(-ano_licitacao, -cd_tipo_modalidade)
  }

  contratos_pe <- contratos_pe %>% 
    dplyr::inner_join(licitacao_df, by = c("cd_orgao", "nr_licitacao", "id_estado"))
  
  
  contratos_rs <- contrato_df %>% filter(id_estado == "43")
  
  if (nrow(contratos_rs) > 0) {
    contratos_rs <- contratos_rs %>%
      dplyr::inner_join(
        licitacao_df,
        by = c(
          "cd_orgao",
          "nr_licitacao",
          "ano_licitacao",
          "cd_tipo_modalidade",
          "id_estado"
        )
      )
  }
  contratos <- bind_rows(contratos_pe, contratos_rs)
  
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
    dplyr::inner_join(contrato_df %>% dplyr::select(cd_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade,
                                                    nr_contrato, ano_contrato, tp_instrumento_contrato,
                                                    id_contrato), 
                      by = c("cd_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade", 
                                          "nr_contrato", "ano_contrato", "tp_instrumento_contrato"))
}

join_licitante_e_licitacao <- function(licitante_df, licitacao_df) {
  licitante_df %>% 
    dplyr::inner_join(licitacao_df, by = c("cd_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade", "id_estado"))
}

join_empenho_e_orgao <- function(empenhos, orgao_municipio) {
  empenhos %<>% dplyr::left_join(orgao_municipio)
}

join_licitacao_e_orgao <- function(licitacoes, orgao_municipio) {
  licitacoes %<>% dplyr::left_join(orgao_municipio)
}

join_contrato_e_orgao <- function(contratos, orgao_municipio) {
  contratos %<>% dplyr::left_join(orgao_municipio)
}

join_itens_contratos_e_licitacoes <- function(itens_contratos, itens_licitacoes) {
  if (nrow(itens_licitacoes) == 0) {
    return(itens_contratos %>% mutate(id_item_licitacao = NA_character_))
  }
  itens_licitacoes %<>% dplyr::select(id_licitacao, id_item_licitacao = id_item, 
                                      nr_lote, nr_item) 
  itens_contratos %<>% dplyr::left_join(itens_licitacoes, c("id_licitacao", "nr_lote", "nr_item"))
    
}

join_contratos_e_fornecedores <- function(fornecedores_df, contratos_df) {
  fornecedores_df %>% 
    dplyr::inner_join(contratos_df, 
                      by = c("nr_documento" = "nr_documento_contratado"))
}

join_empenhos_e_contratos <- function(empenhos_df, contratos_df) {
  empenhos_df %>% 
    dplyr::left_join(contratos_df %>% 
                       dplyr::mutate(nr_licitacao = as.character(nr_licitacao),
                              nr_contrato = as.character(nr_contrato)) %>% 
                       dplyr::select(id_contrato, id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade,
                              nr_contrato, ano_contrato, tp_instrumento_contrato),
                      by = c("id_orgao", "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade", 
                             "nr_contrato", "ano_contrato", "tp_instrumento_contrato"))
}

join_licitacoes_e_documentos <- function(documentos_licitacao_df, licitacoes_df) {
  licitacoes_df %<>% dplyr::select("cd_orgao", "ano_licitacao", "cd_tipo_modalidade", "nr_licitacao", "id_licitacao")
  documentos_licitacao_df %>% 
    dplyr::inner_join(licitacoes_df,
                      by = c("cd_orgao", "ano_licitacao", "cd_tipo_modalidade", "nr_licitacao"))
}

join_documento_e_tipo <- function(documentos_licitacao_df, tipos_documentos_licitacao_df) {
  documentos_licitacao_df %>% 
    dplyr::left_join(tipos_documentos_licitacao_df, by = c("cd_tipo_documento" = "tipo_documento"))
}

join_itens_contratos_e_licitacoes_encerradas <- function(itens_contratos_df, licitacoes_encerradas_df) {
  itens_contratos_df %>%
    dplyr::left_join(
      licitacoes_encerradas_df %>%
        dplyr::select(
          cd_orgao,
          ano_licitacao,
          cd_tipo_modalidade,
          nr_licitacao,
          data_evento
        ),
      by = c(
        "id_orgao" = "cd_orgao",
        "ano_licitacao",
        "cd_tipo_modalidade",
        "nr_licitacao"
      )
    )
}

join_compras_e_licitacoes <- function(compras_df, licitacoes_df) {
  compras_rs <- compras_df %>% filter(id_estado == "43")
  
  if (nrow(compras_rs) > 0) {
  compras_rs <- compras_rs %>% 
    dplyr::inner_join(licitacoes_df %>%
                       dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, id_estado,
                                     id_licitacao),
                     by = c("cd_orgao", "nr_licitacao", "ano_licitacao", "cd_tipo_modalidade", "id_estado"))
  }

  compras_federal <- compras_df %>% filter(id_estado == "99")
  
  if ("ano_licitacao" %in% names(compras_federal)) {
    compras_federal <- compras_federal %>% 
      dplyr::select(-ano_licitacao)
  }
  
  if (nrow(compras_federal) > 0) {
    flog.info(str_glue("Foram encontradas {compras_federal %>% nrow()} compras federais."))
    compras_federal <- compras_federal %>%
      dplyr::inner_join(
        licitacoes_df %>%
          dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, id_estado,
                        id_licitacao) %>% 
          filter(id_estado == "99"),
        by = c(
          "cd_orgao_lic" = "cd_orgao",
          "nr_licitacao",
          "cd_tipo_modalidade",
          "id_estado"
        )
      )
    flog.info(str_glue("{compras_federal %>% nrow()} tem licitações associadas e estão presentes nos dados processados."))
  }
  
  compras <- bind_rows(compras_rs, compras_federal)

  return(compras)
}

join_compras_e_orgaos <- function(compras_df, orgaos_df) {
  compras_rs <- compras_df %>% filter(id_estado == "43")
  
  if ("nm_orgao" %in% names(compras_rs)) {
    compras_rs <- compras_rs %>% 
      dplyr::select(-nm_orgao)
  }
  
  if (nrow(compras_rs) > 0) {
  compras_rs <- compras_rs %>% 
    dplyr::inner_join(orgaos_df %>%
                        dplyr::select(cd_orgao, id_estado, id_orgao, nm_orgao),
                      by = c("cd_orgao", "id_estado"))
  }
  
  compras_federal <- compras_df %>% filter(id_estado == "99")
  
  if ("nm_orgao" %in% names(compras_federal)) {
    compras_federal <- compras_federal %>% 
      dplyr::select(-nm_orgao)
  }

  if (nrow(compras_federal) > 0) {
    compras_federal <- compras_federal %>%
      dplyr::left_join(
        orgaos_df %>%
          dplyr::select(cd_orgao, id_estado, id_orgao, nm_orgao),
        by = c(
          "cd_orgao",
          "id_estado"
        )
      )
  }
  
  compras <- bind_rows(compras_rs, compras_federal)
  
  return(compras)
}
