library(tidyverse)
library(magrittr)
library(futile.logger)
source(here::here("transformer/utils/read_utils.R"))
source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/constants.R"))
source(here::here("transformer/processor/estados/PE/contratos/processador_contratos_pe.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_contratos_rs.R"))
source(here::here("transformer/processor/geral/alertas/processa_itens_fornecedores.R"))
source(here::here("transformer/processor/aggregator/agrega_contratos.R"))

#' Cria dataframe com os tipos de alertas
#' 
#' @return Dataframe com tipos de alertas
#' 
#' @examples 
#' alertas <- create_tipo_alertas()
create_tipo_alertas <- function() {
  id_tipo <- c(1,2)
  titulo <- c("Contratado logo após a abertura", "Produtos atípicos")
  
  tipos_alertas <- data.frame(id_tipo, titulo)
  flog.info(str_glue("{tipos_alertas %>% nrow()} tipos de alertas gerados"))
  
  return(tipos_alertas)
}

#' Processa alertas referentes aos CNAEs principais atípicos no fornecimento de determinados itens
#' 
#' @param anos Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @return Dataframe com alertas para CNAEs atípicos
#' 
#' @examples 
#' alertas <- processa_alertas_cnaes_atipicos_itens()
processa_alertas_cnaes_atipicos_itens <- function(filtro) {
  flog.info("Processando alertas de itens atípicos por atividade econômica...")
  LIMITE_MIN_PROP_CNAE = .01
  flog.info(str_glue("Limite de corte para a proporção de venda de um produto { LIMITE_MIN_PROP_CNAE }"))

  cnaes_itens_fornecedor <- processa_itens_cnaes_fornecedores()
  
  flog.info(str_glue("Tabela com casos de cnaes para serem ignorados na geração do alerta"))
  cnaes_falsos_positivos <- read_csv(here::here("transformer/processor/geral/alertas/cnaes_desconsiderados_produtos.csv"),
                                     col_types = cols(.default = col_character())) %>% 
    filter(assunto %in% c(filtro, "geral")) %>% 
    distinct(id_estado, id_cnae)
  print(cnaes_falsos_positivos)
  
  cnaes_atipicos_data <- cnaes_itens_fornecedor %>% 
    group_by(id_estado, id_contrato, razao_social, nr_documento_contratado, item_class) %>% 
    arrange(desc(prop_grupo_total_item)) %>% 
    mutate(max_prop_total_item = max(prop_grupo_total_item)) %>% 
    ungroup() %>% 
    filter(is_cnae_fiscal == 't') %>% 
    mutate(id_tipo = 2) %>% 
    mutate(nr_documento = nr_documento_contratado) %>% 
    mutate(atipico = max_prop_total_item <= LIMITE_MIN_PROP_CNAE) %>% 
    filter(atipico) %>% 
    anti_join(cnaes_falsos_positivos, by = c("id_estado", "id_cnae"))
  
  flog.info(str_glue("{ cnaes_atipicos_data %>% nrow } casos de itens atípicos detectados"))
  
  cnaes_atipicos_alt <- cnaes_atipicos_data %>% 
    generate_hash_id(c("id_contrato", "id_item_contrato", "id_tipo"), ITEM_ATIPICO) %>% 
    generate_hash_id(c("id_tipo", "nr_documento", "id_contrato"), ALERTA_ID) %>% 
    dplyr::select(id_item_atipico, id_alerta, id_item_contrato, id_contrato, id_estado,
                  nr_documento, id_tipo, ds_item, total_vendas_item = qt_total_item, 
                  n_vendas_semelhantes = qt_total_item_grupo, perc_vendas_semelhantes = prop_grupo_total_item) 
    
  contratos_itens_atipicos <- cnaes_atipicos_alt %>%
    group_by(id_estado, id_contrato, nr_documento, id_tipo) %>% 
    summarise(total_itens_atipicos=n(), .groups = 'drop') %>% 
    arrange(desc(total_itens_atipicos)) %>% 
    mutate(info=ifelse(total_itens_atipicos != 1, 
                       paste0("A empresa forneceu ", total_itens_atipicos, 
                              " produtos que não são comuns com base em suas atividades econômicas declaradas na Receita Federal"),
                       paste0("A empresa forneceu ", total_itens_atipicos, 
                              " produto que não é comum com base em suas atividades econômicas declaradas na Receita Federal"))) %>% 
    ungroup() %>% 
    select(nr_documento, id_contrato, id_tipo, info)
  
  flog.info(str_glue("{ contratos_itens_atipicos %>% nrow } alertas de produtos atípicos"))
    
  readr::write_csv(cnaes_atipicos_alt %>% select(-c(nr_documento, id_tipo, id_estado)), 
                   here::here("data/bd/itens_atipicos.csv"))
    
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
  flog.info(str_glue("Processando alertas da data de abertura!"))
  LIMITE_DIFERENCA_DIAS = 30
  flog.info(str_glue("Diferença de dias entre a abertura e o primeiro contrato: {LIMITE_DIFERENCA_DIAS}"))
  
  fornecedores_tce <- read_fornecedores_processados()
  
  fornecedores_receita <- read_dados_cadastrais_processados()
  
  fornecedores <- fornecedores_tce %>% 
    left_join(fornecedores_receita %>% 
                select(cnpj, razao_social, nome_fantasia, codigo_natureza_juridica, data_inicio_atividade,
                       porte_empresa),
              by = c("nr_documento" = "cnpj")) %>% 
    mutate(diferenca_abertura_contrato = as.numeric(difftime(data_primeiro_contrato, data_inicio_atividade, units="days"))) %>% 
    filter(diferenca_abertura_contrato <= LIMITE_DIFERENCA_DIAS)
  
  flog.info(str_glue("{fornecedores %>% nrow()} fornecedores com o alerta!"))
  
  contratos_merge <- .processa_contratos_info(anos)
  flog.info(str_glue("Pesquisa feita em {contratos_merge %>% nrow()} contratos de {contratos_merge %>% count(id_estado) %>% nrow()} estados."))
  
  fornecedores_contratos <- fornecedores %>% 
    left_join(contratos_merge, by = c("nr_documento" = "nr_documento_contratado", 
                                      "data_primeiro_contrato" = "dt_inicio_vigencia"))
  
  alertas_data <- fornecedores_contratos %>% 
    mutate(id_tipo = 1) %>% 
    mutate(info = paste0("Contrato ", nr_contrato, "/", ano_contrato, " em ", nm_orgao)) %>% 
    select(nr_documento, id_contrato, id_tipo, info) %>% 
    distinct(nr_documento, info, .keep_all = TRUE)
  
  flog.info(str_glue("{alertas_data %>% nrow()} alertas de data de abertura gerados!"))
  
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
    select(id_contrato, id_estado, id_orgao, cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, 
           nr_contrato, ano_contrato, tp_instrumento_contrato,
           nm_orgao, nr_documento_contratado, dt_inicio_vigencia, vl_contrato, 
           descricao_objeto_contrato)

  todos_contratos <- agrega_contratos(anos)
  
  contratos_merge <- contratos_processados %>% 
    bind_rows(todos_contratos) %>% 
    distinct(id_estado, cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, 
             nr_contrato, ano_contrato, tp_instrumento_contrato, .keep_all = T)
  
  return(contratos_merge)
}

