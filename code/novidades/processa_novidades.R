gather_licitacoes <- function(licitacoes, orgao_municipio) {
  licitacoes %<>% dplyr::left_join(orgao_municipio) %>% 
    dplyr::select(id_licitacao, data_abertura, data_homologacao, 
                  data_adjudicacao, nome_municipio, ano_licitacao) %>% 
    tidyr::gather("evento","data",2:4)
}

gather_empenhos <- function(empenhos) {
  empenhos %<>% dplyr::select(id_empenho, id_licitacao, dt_operacao, 
                              vl_empenho, vl_liquidacao, vl_pagamento) %>% 
    tidyr::gather("evento","valor",4:6) %>% na.omit(data)
}

create_tipo_novidades <- function() {
  id_tipo <- c(1, 2, 3, 4, 5, 6, 7, 8, 9)
  texto_evento <- c("Abertura de licitação", "Licitação homologada", 
                    "Licitação adjudicada", "Empenho realizado no valor de ",
                    "Liquidação realizada no valor de ", "Pagamento realizado no valor de ",
                    "Estorno de empenho realizado no valor de ", "Estorno de liquidação realizado no valor de ",
                    "Estorno de pagamento realizado no valor de ")
  tipos_novidades <- data.frame(id_tipo, texto_evento)
}

transforma_licitacao_em_novidades <- function(licitacoes) {
  novidades <- licitacoes %>%
    dplyr::mutate(id_tipo = dplyr::case_when(
      evento == "data_abertura" ~ 1,
      evento == "data_homologacao" ~ 2,
      evento == "data_adjudicacao" ~ 3
    ), id_original = id_licitacao) %>% 
    dplyr::select(id_novidade, id_tipo, id_licitacao,
                  data, id_original, nome_municipio)
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
    ), data = dt_operacao)
}