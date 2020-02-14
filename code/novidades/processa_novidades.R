gather_licitacoes <- function(licitacoes, orgao_municipio) {
  licitacoes %<>% dplyr::left_join(orgao_municipio) %>% 
    dplyr::select(id_licitacao, data_abertura, data_homologacao, 
                  data_adjudicacao, nome_municipio, ano_licitacao) %>% 
    tidyr::gather("evento","data",2:4)
}

create_tipo_novidades <- function() {
  id_tipo <- c(1, 2, 3)
  texto_evento <- c("Abertura de licitação", 
                    "Licitação homologada", 
                    "Licitação adjudicada")
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