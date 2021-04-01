library(magrittr)
library(tidyverse)

source(here::here("fetcher/config/constants.R"))
source(here::here("fetcher/receita/DAO_Receita.R"))
source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/constants.R"))

.HELP <- "Rscript fetch_dados_receita.R"

receita <- NULL

tryCatch({receita <- DBI::dbConnect(RPostgres::Postgres(),
                                    dbname = RECEITA_DB,
                                    host = RECEITA_HOST,
                                    port = RECEITA_PORT,
                                    user = RECEITA_USER,
                                    password = RECEITA_PASSWORD)
}, error = function(e) print(paste0("Erro ao tentar se conectar ao Banco Receita (Postgres): ", e)))

cnpjs <- readr::read_csv(here::here("data/bd/info_fornecedores_contrato.csv")) %>% 
  dplyr::filter(tp_pessoa == "J") %>% 
  pull(nr_documento)

dados_cnpjs <- fetch_dados_cadastrais(receita, cnpjs) %>% 
  left_join(fetch_porte_empresa_info(),
                   by = c("porte_empresa" = "codigo_porte_empresa")) %>% 
  mutate(porte_empresa = descricao_porte) %>% 
  select(-descricao_porte)

socios <- fetch_socios(receita, cnpjs) %>%
  generate_hash_id(c("cnpj", "cnpj_cpf_socio", "nome_socio"),
                   SOCIOS_ID) %>%
  select(id_socio, dplyr::everything())

cnaes_info <- fetch_cnaes_info(receita) %>%
  rename(id_cnae = cod_cnae)

cnaes_secundarios <- fetch_cnaes_secundarios(receita, cnpjs) %>%
  rename(id_cnae = cnae_secundario) %>%
  filter(id_cnae %in% (cnaes_info %>% dplyr::pull(id_cnae))) %>%
  generate_hash_id(c("cnpj", "id_cnae"),
                   CNAE_ID) %>%
  select(id_cnae_secundario, dplyr::everything())

natureza_juridica <- fetch_natureza_juridica_info(receita) %>% 
  select(codigo_natureza_juridica = cod_subclass_natureza_juridica,
                nome_subclasse_natureza_juridica = nm_subclass_natureza_juridica,
                codigo_classe_natureza_juridica = cod_natureza_juridica,
                nome_classe_natureza_juridica = nm_natureza_juridica)

write_csv(dados_cnpjs, here::here("data/bd/dados_cadastrais.csv"))
write_csv(socios, here::here("data/bd/socios.csv"))
write_csv(cnaes_info, here::here("data/bd/info_cnaes.csv"))
write_csv(cnaes_secundarios, here::here("data/bd/cnaes_secundarios.csv"))
write_csv(natureza_juridica, here::here("data/bd/natureza_juridica.csv"))
