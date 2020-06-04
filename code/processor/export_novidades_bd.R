library(magrittr)

help <- "
Usage:
Rscript export_novidades_bd.R
"
source(here::here("code/utils/utils.R"))
source(here::here("code/utils/read_utils.R"))
source(here::here("code/utils/join_utils.R"))
source(here::here("code/utils/constants.R"))
source(here::here("code/novidades/processa_novidades.R"))

tipos_novidades <- create_tipo_novidades()

orgao_municipio <- read_orgaos_processados() %>% dplyr::select(id_orgao, nome_municipio)

licitacoes <- read_licitacoes_processadas() %>% join_licitacao_e_orgao(orgao_municipio) %>% gather_licitacoes() %>% 
  transforma_licitacao_em_novidades()

empenhos <- read_empenhos_processados() %>% join_empenho_e_orgao(orgao_municipio) %>% gather_empenhos() %>% 
  transforma_empenhos_em_novidades()

contratos <- read_contratos_processados() %>% join_contrato_e_orgao(orgao_municipio) %>% gather_contratos() %>% 
  transforma_contrato_em_novidades()

novidades <- dplyr::bind_rows(licitacoes, contratos, empenhos) %>% 
  generate_hash_id(c("id_tipo", "id_licitacao", "id_original"), NOVIDADE_ID) %>% 
  dplyr::select(id_novidade, dplyr::everything())

readr::write_csv(tipos_novidades, here::here("data/bd/tipo_novidade.csv"))
readr::write_csv(novidades, here::here("data/bd/novidade.csv"))
