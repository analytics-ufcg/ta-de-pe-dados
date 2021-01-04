library(magrittr)

source(here::here("code/fetcher/setup/constants.R"))
source(here::here("code/fetcher/DAO_Receita.R"))
source(here::here("code/utils/utils.R"))
source(here::here("code/utils/constants.R"))

.HELP <- "Rscript fetch_dados_receita.R"

receita <- NULL

tryCatch({receita <- DBI::dbConnect(RPostgres::Postgres(),
                                    dbname = RECEITA_DB,
                                    host = RECEITA_HOST,
                                    port = RECEITA_PORT,
                                    user = RECEITA_USER,
                                    password = RECEITA_PASSWORD)
}, error = function(e) print(paste0("Erro ao tentar se conectar ao Banco Receita (Postgres): ", e)))

cnpjs_rs <- readr::read_csv(here::here("data/bd/info_fornecedores_contrato.csv"))$nr_documento

dados_cnpjs_rs <- fetch_dados_cadastrais(receita, cnpjs_rs) %>% 
  dplyr::left_join(fetch_porte_empresa_info(),
                   by = c("porte_empresa" = "codigo_porte_empresa")) %>% 
  dplyr::mutate(porte_empresa = descricao_porte) %>% 
  dplyr::select(-descricao_porte)

socios_rs <- fetch_socios(receita, cnpjs_rs) %>%
  generate_hash_id(c("cnpj", "cnpj_cpf_socio", "nome_socio"),
                   SOCIOS_ID) %>%
  dplyr::select(id_socio, dplyr::everything())

cnaes_info <- fetch_cnaes_info(receita) %>%
  dplyr::rename(id_cnae = cod_cnae)

cnaes_secundarios_rs <- fetch_cnaes_secundarios(receita, cnpjs_rs) %>%
  dplyr::rename(id_cnae = cnae_secundario) %>%
  dplyr::filter(id_cnae %in% (cnaes_info %>% dplyr::pull(id_cnae))) %>%
  generate_hash_id(c("cnpj", "id_cnae"),
                   CNAE_ID) %>%
  dplyr::select(id_cnae_secundario, dplyr::everything())

natureza_juridica <- fetch_natureza_juridica_info(receita) %>% 
  dplyr::select(codigo_natureza_juridica = cod_subclass_natureza_juridica,
                nome_subclasse_natureza_juridica = nm_subclass_natureza_juridica,
                codigo_classe_natureza_juridica = cod_natureza_juridica,
                nome_classe_natureza_juridica = nm_natureza_juridica)

readr::write_csv(dados_cnpjs_rs, here::here("data/bd/dados_cadastrais.csv"))
readr::write_csv(socios_rs, here::here("data/bd/socios.csv"))
readr::write_csv(cnaes_info, here::here("data/bd/info_cnaes.csv"))
readr::write_csv(cnaes_secundarios_rs, here::here("data/bd/cnaes_secundarios.csv"))
readr::write_csv(natureza_juridica, here::here("data/bd/natureza_juridica.csv"))
