source(here::here("code/utils/read_utils.R"))

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


#' Prepara dados para tabela de licitações de merenda
#'
#' @param anos Vector de inteiros com anos para captura das licitações
#'
#' @return Dataframe com informações das licitações de merenda
#'   
#' @examples 
#' licitacoes_merenda <- processa_info_licitacoes(2019)
#' 
#' Chave primária:
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade)
#' 
processa_info_empenhos <- function(empenhos_df) {
  
  empenhos_df %<>% dplyr::select(id_licitacao, ano_recebimento, mes_recebimento, id_orgao = cd_orgao, nome_orgao, cd_orgao_orcamentario,
                                 nome_orgao_orcamentario, cd_unidade_orcamentaria, nome_unidade_orcamentaria, tp_unidade, 
                                 tipo_operacao, ano_empenho, ano_operacao, 
                                 dt_empenho, dt_operacao, nr_empenho, historico, cd_funcao, ds_funcao, cd_subfuncao, ds_subfuncao, cd_programa, 
                                 ds_programa, cd_projeto, nm_projeto, cd_recurso, nm_recurso, cd_credor, nm_credor, cnpj_cpf, vl_empenho, 
                                 nr_liquidacao, vl_liquidacao, nr_pagamento, vl_pagamento, ano_licitacao, nr_licitacao, 
                                 cd_tipo_modalidade = mod_licitacao, ano_contrato, nr_contrato, 
                                 tp_instrumento_contrato = tp_instrumento_contratual
                                 )
    
  
  return(empenhos_df)
}
