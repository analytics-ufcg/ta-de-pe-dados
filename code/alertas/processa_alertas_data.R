library(tidyverse)
source(here::here("code/utils/read_utils.R"))
source(here::here("code/contratos/processa_contratos.R"))

#' Cria dataframe com os tipos de alertas
#' 
#' @return Dataframe com tipos de alertas
#' 
#' @examples 
#' alertas <- create_tipo_alertas()
create_tipo_alertas <- function() {
  id_tipo <- c(1)
  titulo <- c("Contratado logo após a abertura.")
  
  tipos_alertas <- data.frame(id_tipo, titulo)
}

#' Processa alertas de fornecedores com relação a diferença entre a data de abertura e a data do primeiro contrato
#' 
#' @param anos Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @return Dataframe com alertas para a diferença de datas
#' 
#' @examples 
#' alertas <- processa_alertas_data_abertura_contrato(c(2018, 2019, 2020))
processa_alertas_data_abertura_contrato <- function(anos) {
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
    mutate(info_contrato = paste0("Contrato ", nr_contrato, "/", ano_contrato, " em ", nm_orgao)) %>% 
    select(nr_documento, id_contrato, id_tipo, info_contrato)
  
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
