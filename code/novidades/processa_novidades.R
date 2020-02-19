gather_licitacoes <- function(licitacoes, orgao_municipio) {
  licitacoes %<>% dplyr::left_join(orgao_municipio) %>% 
    dplyr::select(id_licitacao, data_abertura, data_homologacao, 
                  data_adjudicacao, nome_municipio, ano_licitacao) %>% 
    tidyr::gather("evento","data",2:4)
}

gather_empenhos <- function(empenhos, orgao_municipio) {
  empenhos %<>% dplyr::left_join(orgao_municipio) %>% 
    dplyr::select(id_empenho, id_licitacao, dt_operacao, 
                  vl_empenho, vl_liquidacao, vl_pagamento,
                  nome_municipio) %>% 
    tidyr::gather("evento","valor",4:6) %>% na.omit(data)
}

create_tipo_novidades <- function() {
  id_tipo <- c(1, 2, 3, 4, 5, 6, 7, 8, 9)
  texto_evento <- c("Abertura de licitação", "Licitação homologada", 
                    "Licitação adjudicada", "Empenho",
                    "Liquidação", "Pagamento",
                    "Estorno de empenho", "Estorno de liquidação",
                    "Estorno de pagamento")
  tipos_novidades <- data.frame(id_tipo, texto_evento)
}

transforma_licitacao_em_novidades <- function(licitacoes) {
  novidades <- licitacoes %>%
    dplyr::mutate(id_tipo = dplyr::case_when(
      evento == "data_abertura" ~ 1,
      evento == "data_homologacao" ~ 2,
      evento == "data_adjudicacao" ~ 3
    ), id_original = id_licitacao, texto_novidade = NA) %>% 
    dplyr::select(id_tipo, id_licitacao, data, id_original, 
                  nome_municipio, texto_novidade)
}

transforma_empenhos_em_novidades <- function(empenhos) {
  novidades <- empenhos %>% 
    dplyr::mutate(id_tipo = dplyr::case_when(
      (evento == "vl_empenho" & valor >= 0) ~ 4,
      (evento == "vl_liquidacao" & valor >= 0) ~ 5,
      (evento == "vl_pagamento" & valor >= 0) ~ 6,
      (evento == "vl_empenho" & valor < 0) ~ 7,
      (evento == "vl_liquidacao" & valor < 0) ~ 8,
      (evento == "vl_pagamento" & valor < 0) ~ 9
    ), texto_novidade = dplyr::case_when(
      id_tipo == 4 ~ paste0("Empenho realizado no valor de R$ ", valor),
      id_tipo == 5 ~ paste0("Liquidação realizada no valor de R$ ", valor),
      id_tipo == 6 ~ paste0("Pagamento realizado no valor de R$ ", valor),
      id_tipo == 7 ~ paste0("Estorno de empenho realizado no valor de R$ ", valor),
      id_tipo == 8 ~ paste0("Estorno de liquidação realizado no valor de R$ ", valor),
      id_tipo == 9 ~ paste0("Estorno de pagamento realizado no valor de R$ ", valor),
    ), data = dt_operacao, id_original = id_empenho) %>% 
    dplyr::select(id_tipo, id_licitacao, data, id_original, 
                  nome_municipio, texto_novidade)
}