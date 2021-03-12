library(tidyverse)
library(tidyselect)
source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/read_utils.R"))

#' Processa dados de empenhos do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos empenhos
#' 
#' @return Dataframe com informações dos empenhos
#' 
#' @examples 
#' empenhos <- import_licitacoes(2019)
#' 
import_empenhos <- function(ano) {
  
  empenhos <- purrr::pmap_dfr(list(ano),
                                ~ import_empenhos_por_ano(..1)
  )
  
  return(empenhos)
}

#' Importa dados de empenhos em um ano específico para o estado do Rio Grande do Sul
#' @param ano Inteiro com o ano para recuperação dos empenhos
#' @return Dataframe com informações dos empenhos
#' @examples 
#' empenhos <- import_empenhos_por_ano(2019)
#' 
import_empenhos_por_ano <- function(ano) {
  message(paste0("Importando empenhos do ano ", ano))
  empenhos <- read_empenhos(ano)
  
  return(empenhos)
}


#' Prepara dados para tabela de licitações
#'
#' @param anos Vector de inteiros com anos para captura das licitações
#'
#' @return Dataframe com informações das licitações
#'   
#' @examples 
#' licitacoes <- adapta_info_licitacoes(2019)
#' 
#' Chave primária:
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade)
#' 
adapta_info_empenhos <- function(empenhos_df) {
  
  empenhos_df %<>% dplyr::select(id_licitacao, ano_recebimento, mes_recebimento, id_orgao = cd_orgao, nome_orgao, cd_orgao_orcamentario,
                                 nome_orgao_orcamentario, cd_unidade_orcamentaria, nome_unidade_orcamentaria, tp_unidade, 
                                 tipo_operacao, ano_empenho, ano_operacao, 
                                 dt_empenho, dt_operacao, nr_empenho, historico, cd_funcao, ds_funcao, cd_subfuncao, ds_subfuncao, cd_programa, 
                                 ds_programa, cd_projeto, nm_projeto, cd_recurso, nm_recurso, cd_credor, nm_credor, tp_pessoa, cnpj_cpf, vl_empenho, 
                                 nr_liquidacao, vl_liquidacao, nr_pagamento, vl_pagamento, ano_licitacao, nr_licitacao, 
                                 cd_tipo_modalidade = mod_licitacao, ano_contrato, nr_contrato, 
                                 tp_instrumento_contrato = tp_instrumento_contratual
                                 )
    
  
  return(empenhos_df)
}

#' Recupera informações dos contratos relacionados a empenhos em fases anteriores
#'
#' @param empenhos_df Dataframe de empenhos
#'
#' @return Dataframe com informações dos ids dos contratos ligados aos empenhos
#'   
#' @examples 
#' empenhos_contratos <- adapta_id_contrato_empenhos(empenhos_df)
#' 
adapta_id_contrato_empenhos <- function(empenhos_df) {
  chave_empenhos_contratos <- c("ano_recebimento", "mes_recebimento", "id_orgao", "cd_orgao_orcamentario", "nome_orgao_orcamentario", 
                                "cd_unidade_orcamentaria", "nome_unidade_orcamentaria", "tp_unidade", "dt_empenho", "ano_empenho", 
                                "ano_operacao", "nr_empenho", "cd_credor", "cnpj_cpf",
                                "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade", "ano_contrato", "nr_contrato", "tp_instrumento_contrato"
  )
  
  chave_empenhos <- c("ano_recebimento", "mes_recebimento", "id_orgao", "cd_orgao_orcamentario", "nome_orgao_orcamentario",
                      "cd_unidade_orcamentaria", "nome_unidade_orcamentaria", "tp_unidade", 
                      "dt_empenho", "ano_empenho", "ano_operacao", "nr_empenho", "cd_credor", "cnpj_cpf",
                      "ano_licitacao", "nr_licitacao", "cd_tipo_modalidade"
  )

  ## Recupera empenhos ligados a um único contrato
  empenhos_com_contratos <-
    empenhos_df %>% 
    dplyr::filter(!is.na(ano_contrato),!is.na(nr_contrato),!is.na(tp_instrumento_contrato)) %>%
    dplyr::group_by_at(.vars = vars(tidyselect::all_of(chave_empenhos_contratos))) %>%
    dplyr::summarise(n = n()) %>%
    dplyr::ungroup() %>%
    dplyr::select(-n) %>% 
    dplyr::group_by_at(.vars = vars(tidyselect::all_of(chave_empenhos))) %>%
    dplyr::mutate(n = n()) %>%
    dplyr::ungroup() %>% 
    dplyr::filter(n == 1) %>% 
    dplyr::select(-n) %>%
    mutate(nr_licitacao = as.character(nr_licitacao),
           nr_contrato = as.character(nr_contrato)) %>% 
    join_empenhos_e_contratos(contratos_df)
  
  ## Recupera o id para os empenhos, liquidações e pagamentos quando a info do contrato tiver acontecido em alguma fase do empenho.
  empenhos_com_id_contrato <- empenhos_df %>%
    filter(is.na(id_contrato)) %>%
    select(-ano_contrato,
           -nr_contrato,
           -tp_instrumento_contrato,
           -id_contrato) %>% 
    mutate(nr_licitacao = as.character(nr_licitacao)) %>% 
    left_join(
      empenhos_com_contratos,
      by = chave_empenhos
    )
  
  ## Junta empenhos com ids recuperados (antigos e novos)
  empenhos_df_alt <- empenhos_df %>% 
    mutate(nr_licitacao = as.character(nr_licitacao),
           nr_contrato = as.character(nr_contrato)) %>% 
    filter(!is.na(id_contrato)) %>% 
    bind_rows(empenhos_com_id_contrato)
  
  return(empenhos_df_alt)
}
