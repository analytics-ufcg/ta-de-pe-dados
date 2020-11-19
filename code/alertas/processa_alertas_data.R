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
  titulo <- c("Contratado logo após a abertura.", "CNAE principal atípico no fornecimento do item.")
  
  tipos_alertas <- data.frame(id_tipo, titulo)
}

#' Processa alertas referentes aos CNAEs principais atípicos no fornecimento de determinados itens
#' 
#' @param anos Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @return Dataframe com alertas para CNAEs atípicos
#' 
#' @examples 
#' alertas <- processa_alertas_cnaes_atipicos_itens(c(2018, 2019, 2020))
processa_alertas_cnaes_atipicos_itens <- function(anos) {
  print("Processando alertas de CNAEs atípicos por item...")
  LIMITE_MIN_FREQUENCIA_CNAE = .01
  
  contratos_processados <- read_contratos_processados() %>% 
    filter(nchar(nr_documento_contratado) == 14) %>% 
    select (id_contrato, nr_documento_contratado, nr_contrato, nr_documento, ano_contrato, nm_orgao) #contrato_1
  
  itens_contratos_processados <- read_itens_contrato_processados() #item_contrato_2
  dados_cadastrais_processados <- read_dados_cadastrais_processados() %>% 
    select(cnpj, razao_social, nome_fantasia, cnae_fiscal) #dados_cadastrais_3
  
  cnaes_processados <- read_cnaes_processados() %>% 
    select(id_cnae, nm_cnae, nm_classe, nm_grupo, nm_divisao, nm_secao)#cnae_4
  
  cnaes_secundarios_processados <- read_cnaes_secundarios_processados() %>% 
    select (cnpj, id_cnae) #cnae_secundario_5
  
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
  
  itens <- itens_unicos_similaridade_rs
  
  itens_separated <- separate_rows(itens, ids_itens_contratos, convert = TRUE) %>% 
    mutate (id_item_contrato = ids_itens_contratos) %>% 
    select (-c(ids_itens_contratos)) %>% 
    filter (id_item_contrato != "") %>% 
    mutate (item_class = ds_item)
  
  cnae_fiscal_itens_unicos <- cnae_fiscal_itens %>% 
    left_join(itens_separated %>% select(c(id_item_contrato, item_class)), by="id_item_contrato")
  
  cnae_all_itens_unicos <- all_cnaes %>%
    left_join(itens_separated %>% select(c(id_item_contrato, item_class)), by="id_item_contrato")
  
  total_item_cnae_df <- cnae_fiscal_itens_unicos %>% 
    select (item_class,  nm_cnae) %>% 
    group_by(item_class, nm_cnae) %>% 
    mutate(qt_total_item_cnae = n())%>%
    unique() %>% 
    arrange(desc(qt_total_item_cnae))
  
  cnae_all_itens_unicos_totais <- cnae_all_itens_unicos%>% 
    left_join(total_item_df, by="item_class") %>%
    left_join(total_cnae_df, by="nm_cnae")%>%
    left_join(total_item_cnae_df, by=c("nm_cnae", "item_class")) %>% 
    mutate(perc= qt_total_item_cnae/qt_total_item) %>%
    arrange(desc(perc))
  
  cnae_all_totais_selected <- cnae_all_itens_unicos_totais %>% 
    select("id_cnae", "id_item_contrato", "id_contrato", "ds_item", "nr_contrato", "ano_contrato", "nm_orgao", 
           "razao_social", "nr_documento_contratado", "is_cnae_fiscal", 
           "nm_cnae", "item_class","qt_total_item", "qt_total_cnae", 
           "qt_total_item_cnae", "perc") %>%
    mutate_all(funs(ifelse(is.na(.), 0, .))) %>% 
    filter(qt_total_item>=10)  
    
  
  cnaes_atipicos_data <- cnae_all_totais_selected %>% 
    group_by(id_contrato, razao_social, nr_documento_contratado, item_class) %>% 
    arrange(desc(perc)) %>% 
    mutate(max_perc = max(perc)) %>% 
    filter(is_cnae_fiscal == 't') %>% 
    mutate(id_tipo = 2) %>% 
    mutate(nr_documento = nr_documento_contratado) %>% 
    mutate(info=paste0("A empresa ", razao_social," não possui nenhuma atividade econômica frequente para o item ", 
                       ds_item," no contrato ",nr_contrato, "/", ano_contrato, " em ", nm_orgao,".")) %>% 
    filter(max_perc <= LIMITE_MIN_FREQUENCIA_CNAE) %>% 
    ungroup()%>% 
    select("nr_documento", "id_contrato",	"id_tipo", "info")
  
  return(cnaes_atipicos_data)
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
