library(tidyverse)
source(here::here("code/utils/read_utils.R"))
source(here::here("code/contratos/processa_contratos.R"))
source(here::here("code/fetcher/scripts/fetcher_ta_na_mesa.R"))

#' Cria dataframe com os tipos de alertas
#' 
#' @return Dataframe com tipos de alertas
#' 
#' @examples 
#' alertas <- create_tipo_alertas()
create_tipo_alertas <- function() {
  id_tipo <- c(1,2)
  titulo <- c("Contratado logo após a abertura.", "Produtos atípicos.")
  
  tipos_alertas <- data.frame(id_tipo, titulo)
}

#' Processa alertas referentes aos CNAEs principais atípicos no fornecimento de determinados itens
#' 
#' @param anos Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @return Dataframe com alertas para CNAEs atípicos
#' 
#' @examples 
#' alertas <- processa_alertas_cnaes_atipicos_itens()
processa_alertas_cnaes_atipicos_itens <- function() {
  print("Processando alertas de itens atípicos por atividade econômica...")
  LIMITE_MIN_PROP_CNAE = .01
  
  cnaes_itens_forcenedor <- .processa_itens_cnaes_fornecedores()
  
  cnaes_atipicos_data <- cnaes_itens_forcenedor %>% 
    group_by(id_contrato, razao_social, nr_documento_contratado, item_class) %>% 
    arrange(desc(prop_grupo_total_item)) %>% 
    mutate(max_prop_total_item = max(prop_grupo_total_item)) %>% 
    filter(is_cnae_fiscal == 't') %>% 
    mutate(id_tipo = 2) %>% 
    mutate(nr_documento = nr_documento_contratado) %>% 
    mutate(atipico = max_prop_total_item <= LIMITE_MIN_PROP_CNAE) %>% 
    filter(atipico) %>% 
    generate_hash_id(c("id_contrato", "id_item_contrato", "id_tipo"), ITEM_ATIPICO) %>% 
    generate_hash_id(c("id_tipo", "nr_documento", "id_contrato"), ALERTA_ID) %>% 
    dplyr::select(id_item_atipico, id_alerta, id_item_contrato, id_contrato, nr_documento, id_tipo, ds_item) 
    
  contratos_itens_atipicos <- cnaes_atipicos_data %>%
    group_by(id_contrato, nr_documento, id_tipo) %>% 
    summarise(total_itens_atipicos=n(), .groups = 'drop') %>% 
    arrange(desc(total_itens_atipicos)) %>% 
    mutate(info=ifelse(total_itens_atipicos != 1, 
                       paste0("A empresa forneceu ", total_itens_atipicos, 
                              " produtos que não são comuns com base em suas atividades econômicas declaradas na Receita Federal"),
                       paste0("A empresa forneceu ", total_itens_atipicos, 
                              " produto que não é comum com base em suas atividades econômicas declaradas na Receita Federal"))) %>% 
    ungroup() %>% 
    select(nr_documento, id_contrato, id_tipo, info)
    
  readr::write_csv(cnaes_atipicos_data %>% select(-c(nr_documento, id_tipo)), here::here("data/bd/itens_atipicos.csv"))
    
  return(contratos_itens_atipicos)
}

#' Processa alertas de fornecedores com relação a diferença entre a data de abertura e a data do primeiro contrato
#' 
#' @param anos Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @return Dataframe com alertas para a diferença de datas
#' 
#' @examples 
#' alertas <- processa_alertas_data_abertura_contrato(c(2018, 2019, 2020))
processa_alertas_data_abertura_contrato <- function(anos) {
  print("Processando alertas da data de abertura...")
  LIMITE_DIFERENCA_DIAS = 30
  
  fornecedores_tce <- read_fornecedores_processados()
  
  fornecedores_receita <- read_dados_cadastrais_processados()
  
  fornecedores <- fornecedores_tce %>% 
    left_join(fornecedores_receita %>% 
                select(cnpj, razao_social, nome_fantasia, codigo_natureza_juridica, data_inicio_atividade,
                       porte_empresa),
              by = c("nr_documento" = "cnpj")) %>% 
    mutate(diferenca_abertura_contrato = as.numeric(difftime(data_primeiro_contrato, data_inicio_atividade, units="days"))) %>% 
    filter(diferenca_abertura_contrato < LIMITE_DIFERENCA_DIAS)
  
  contratos_merge <- .processa_contratos_info(anos)
  
  fornecedores_contratos <- fornecedores %>% 
    left_join(contratos_merge, by = c("nr_documento" = "nr_documento_contratado", "data_primeiro_contrato" = "dt_inicio_vigencia"))
  
  alertas_data <- fornecedores_contratos %>% 
    mutate(id_tipo = 1) %>% 
    mutate(info = paste0("Contrato ", nr_contrato, "/", ano_contrato, " em ", nm_orgao)) %>% 
    select(nr_documento, id_contrato, id_tipo, info)
  
  return(alertas_data)
}

#' Agrupa todos os contratos e compras realizadas em um período de tempo. 
#' Os contratos considerados independem do assunto (filtro), já as compras consideradas envolvem apenas contratos do assunto. 
#' 
#' @param anos Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @return Dataframe com alertas para a diferença de daras
#' 
#' @examples 
#' contratos_merge <- .processa_contratos_info(c(2018, 2019, 2020))
.processa_contratos_info <- function(anos) {
  contratos_processados <- read_contratos_processados() %>% 
    mutate(id_orgao = as.character(id_orgao)) %>% 
    select(id_contrato, id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato,
           nm_orgao, nr_documento_contratado, dt_inicio_vigencia, vl_contrato, descricao_objeto_contrato)
  
  contratos <- import_contratos(anos) %>% 
    processa_info_contratos() %>% 
    select(id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato,
           nm_orgao, nr_documento_contratado, dt_inicio_vigencia, vl_contrato, descricao_objeto_contrato)
  
  contratos_merge <- contratos_processados %>% 
    bind_rows(contratos) %>% 
    distinct(id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato, .keep_all = T)
  
  return(contratos_merge)
}


#' Agrupa todos os contratos, cnaes e itens de acordo com um período de tempo. 
#' 
#' @param anos Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @return Dataframe com todos os itens vendidos por determinados CNAES
#' 
#' @examples 
#' cnaes_itens_forcenedor <- .processa_itens_cnaes_fornecedores(c(2018, 2019, 2020))
.processa_itens_cnaes_fornecedores <- function() {
  LIMITE_MIN_ITENS <- 250

  contratos_processados <- read_contratos_processados() %>% 
    filter(nchar(nr_documento_contratado) == 14) %>% 
    select (id_contrato, nr_documento_contratado, nr_contrato, nr_documento_contratado, ano_contrato, nm_orgao) 
  
  itens_contratos_processados <- read_itens_contrato_processados()
  dados_cadastrais_processados <- read_dados_cadastrais_processados() %>% 
    select(cnpj, razao_social, nome_fantasia, cnae_fiscal) 
  
  cnaes_processados <- read_cnaes_processados() %>% 
    select(id_cnae, nm_cnae, nm_classe, nm_grupo, nm_divisao, nm_secao)
  
  cnaes_secundarios_processados <- read_cnaes_secundarios_processados() %>% 
    select (cnpj, id_cnae) 
  
  itens_contrato <- itens_contratos_processados %>%  
    select(id_item_contrato, id_contrato, id_item_licitacao, ds_item, ds_1, ds_2, ds_3) %>% 
    left_join(contratos_processados, by = c("id_contrato"))
  
  itens_contrato_info <- itens_contrato %>% left_join(dados_cadastrais_processados, by = c("nr_documento_contratado" = "cnpj"))
  
  itens_contrato_info_cnae_fiscal <- itens_contrato_info %>% 
    mutate(id_cnae=cnae_fiscal) %>% 
    select(-c(cnae_fiscal)) %>% 
    mutate(is_cnae_fiscal="t")
  
  cnae_secundario_itens <- cnaes_secundarios_processados %>% 
    left_join(itens_contrato_info, by = c("cnpj" = "nr_documento_contratado")) %>% 
    select(-c(cnae_fiscal)) %>% 
    mutate(nr_documento_contratado=cnpj) %>% 
    select(-c(cnpj)) %>% 
    mutate(is_cnae_fiscal="f") %>% 
    left_join(cnaes_processados, by = c("id_cnae")) %>% 
    filter(!is.na(nm_cnae))
  
  cnae_fiscal_itens <- itens_contrato_info_cnae_fiscal %>% left_join(cnaes_processados, by = c("id_cnae"))%>% 
    filter(!is.na(nm_cnae))
  
  all_cnaes <- bind_rows (cnae_secundario_itens, cnae_fiscal_itens) %>% 
    filter(!is.na(nm_cnae))
  
  itens_separated <- separate_rows(itens_unicos_similaridade_rs, ids_itens_contratos, convert = TRUE) %>% 
    mutate (id_item_contrato = ids_itens_contratos) %>% 
    select (-c(ids_itens_contratos)) %>% 
    filter (id_item_contrato != "") %>% 
    mutate (item_class = ds_item)
  
  cnae_fiscal_itens_unicos <- cnae_fiscal_itens %>% 
    left_join(itens_separated %>% select(c(id_item_contrato, item_class)), by="id_item_contrato")
  
  cnae_all_itens_unicos <- all_cnaes %>%
    left_join(itens_separated %>% select(c(id_item_contrato, item_class)), by="id_item_contrato")
  
  total_item_cnae_df <- cnae_fiscal_itens_unicos %>% 
    select (item_class,  nm_grupo) %>% 
    group_by(item_class, nm_grupo) %>% 
    mutate(qt_total_item_grupo = n())%>%
    unique() %>% 
    arrange(desc(qt_total_item_grupo))
  
  total_item_df <- cnae_fiscal_itens_unicos %>% 
    select (item_class) %>% 
    group_by(item_class) %>% 
    mutate(qt_total_item = n())%>%
    unique() %>% 
    arrange(desc(qt_total_item))
  
  cnaes_itens_forcenedor <- cnae_all_itens_unicos %>% 
    left_join(total_item_df, by="item_class") %>%
    left_join(total_item_cnae_df, by=c("nm_grupo", "item_class")) %>% 
    mutate(prop_grupo_total_item= qt_total_item_grupo/qt_total_item) %>%
    select("id_cnae", "id_item_contrato", "id_contrato", "ds_item", "nr_contrato", "ano_contrato", "nm_orgao", 
           "razao_social", "nr_documento_contratado", "is_cnae_fiscal", 
           "nm_grupo","nm_divisao", "item_class","qt_total_item", 
           "qt_total_item_grupo", "prop_grupo_total_item") %>%
    mutate_all(funs(ifelse(is.na(.), 0, .))) %>% 
    filter(qt_total_item>=LIMITE_MIN_ITENS)
  
  return(cnaes_itens_forcenedor)  
}
