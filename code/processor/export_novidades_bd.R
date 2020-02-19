library(magrittr)

help <- "
Usage:
Rscript export_novidades_bd.R
"
source(here::here("code/utils/utils.R"))
source(here::here("code/utils/read_utils.R"))
source(here::here("code/utils/constants.R"))
source(here::here("code/novidades/processa_novidades.R"))

tipos_novidades <- create_tipo_novidades()

orgao_municipio <- read_orgaos_processados() %>% dplyr::select(id_orgao, nome_municipio)

licitacoes <- read_licitacoes_processadas() %>% gather_licitacoes(orgao_municipio)

empenhos <- read_empenhos_processados() %>%  gather_empenhos() %>% transforma_empenhos_em_novidades()

novidades <- licitacoes %>% generate_id(TABELA_NOVIDADE, NOVIDADE_ID) %>% 
  transforma_licitacao_em_novidades()

readr::write_csv(tipos_novidades, here::here("data/bd/tipo_novidade.csv"))
readr::write_csv(novidades, here::here("data/bd/novidade.csv"))
