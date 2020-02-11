library(magrittr)

help <- "
Usage:
Rscript export_novidades_bd.R
"

source(here::here("code/utils/utils.R"))
source(here::here("code/utils/constants.R"))

id_tipo <- c(1, 2, 3)
texto_evento <- c("Abertura de licitação", "Licitação homologada", "Licitação adjudicada")
tipos_novidades <- data.frame(id_tipo, texto_evento)

licitacoes <- readr::read_csv(here::here("./data/bd/info_licitacao.csv"), 
                              col_types = list(
                                .default = readr::col_character(),
                                id_licitacao = readr::col_number(),
                                id_estado = readr::col_number(),
                                id_orgao = readr::col_number(),
                                nr_licitacao = readr::col_number(),
                                ano_licitacao = readr::col_number(),
                                vl_estimado_licitacao = readr::col_number(),
                                data_abertura = readr::col_datetime(format = ""),
                                data_homologacao = readr::col_datetime(format = ""),
                                data_adjudicacao = readr::col_datetime(format = ""),
                                vl_homologado = readr::col_number()
                              ))

orgao_municipio <- readr::read_csv(here::here("./data/bd/info_orgaos.csv"))

orgao_municipio %<>% dplyr::select(id_orgao, nome_municipio)

licitacoes %<>% dplyr::left_join(orgao_municipio) %>% 
  dplyr::select(id_licitacao, data_abertura, data_homologacao, 
                data_adjudicacao, nome_municipio) %>% 
  tidyr::gather("evento","data",2:4)

novidades <- licitacoes %>% generate_id(TABELA_NOVIDADE, NOVIDADE_ID) %>% 
  dplyr::mutate(id_tipo = dplyr::case_when(
    evento == "data_abertura" ~ 1,
    evento == "data_homologacao" ~ 2,
    evento == "data_adjudicacao" ~ 3
  ), id_original = id_licitacao) %>% 
  dplyr::select(id_novidade, id_tipo, id_licitacao,
                data, id_original, nome_municipio)

readr::write_csv(tipos_novidades, here::here("data/bd/tipo_novidade.csv"))
readr::write_csv(novidades, here::here("data/bd/novidade.csv"))
