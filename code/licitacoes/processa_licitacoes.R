library(tidyverse)
library(here)
library(janitor)

#' Processa dados de licitações do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura das licitações
#' 
#' @return Dataframe com informações das licitações
#' 
#' @examples 
#' licitacoes <- import_licitacoes(c(2017, 2018, 2019))
#' 
import_licitacoes <- function(anos = c(2017, 2018, 2019)) {
  
  licitacoes <- pmap_dfr(list(anos),
                         ~ import_licitacoes_por_ano(..1)
                         )
  
  return(licitacoes)
}

#' Importa dados de licitações em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação das licitações
#'
#' @return Dataframe com informações das licitações
#'   
#' @examples 
#' licitacoes <- import_licitacoes_por_ano(2019)
#' 
import_licitacoes_por_ano <- function(ano = 2019) {
  message(paste0("Importando licitações do ano ", ano))
  licitacoes <- read_csv(here(paste0("data/licitacoes/", ano, "/licitacao.csv")), col_types = cols(.default = "c", 
                                                                                                       VL_LICITACAO = "d"))
  
  return(licitacoes)
}

#' Carrega licitações de merenda a partir de um filtro aplicado a todas as licitações
#'
#' @param anos Vector de inteiros com anos para captura das licitações
#'
#' @return Dataframe com informações das licitações de merenda
#'   
#' @examples 
#' licitacoes_merenda <- import_licitacoes_merenda(c(2017, 2018, 2019))
#' 
import_licitacoes_merenda <- function(anos = c(2017, 2018, 2019)) {
  todas_licitacoes <- import_licitacoes(anos)
  
  licitacoes_merenda <- todas_licitacoes %>% 
    filter(CD_TIPO_MODALIDADE == "CPP",
           CD_TIPO_FASE_ATUAL == "ADH")

  return(licitacoes_merenda)
}

#' Prepara dados para tabela de licitações de merenda
#'
#' @param anos Vector de inteiros com anos para captura das licitações
#'
#' @return Dataframe com informações das licitações de merenda
#'   
#' @examples 
#' licitacoes_merenda <- processa_info_licitacoes(c(2017, 2018, 2019))
#' 
processa_info_licitacoes <- function(anos = c(2017, 2018, 2019)) {
  source(here("code/licitacoes/processa_concorrentes.R"))
  source(here("code/licitacoes/processa_tipos_licitacoes.R"))
  
  licitacoes_merenda <- import_licitacoes_merenda(anos)
  
  todos_concorrentes <- import_concorrentes(anos) %>% 
    group_by(CD_ORGAO, ANO_LICITACAO, CD_TIPO_MODALIDADE, NR_LICITACAO) %>%
    summarise(total_concorrentes = n_distinct(NR_DOCUMENTO))
  
  tipo_licitacao <- processa_tipos_licitacoes()

  info_licitacoes <- licitacoes_merenda %>%
    clean_names() %>% 
    mutate(id_estado = "43",
           tp_fornecimento = ifelse(tp_fornecimento == "I" , "Integral", 
                                    ifelse(tp_fornecimento == "P", "Parcelado", NA)),
           vl_homologado = ifelse(vl_homologado == "", NA, vl_homologado),
           dt_adjudicacao = as.Date(dt_adjudicacao, format="%Y-%m-%d"),
           vl_homologado = as.numeric(vl_homologado),
           vl_licitacao = as.numeric(vl_licitacao)) %>%
    
    left_join(tipo_licitacao, by = c("tp_licitacao")) %>%
    left_join(todos_concorrentes, by = c("cd_orgao" = "CD_ORGAO", 
                                         "ano_licitacao" = "ANO_LICITACAO", 
                                         "cd_tipo_modalidade" = "CD_TIPO_MODALIDADE", 
                                         "nr_licitacao" = "NR_LICITACAO")) %>%
    
    select(id_estado, id_orgao = cd_orgao, nr_licitacao, ano_licitacao, tipo_licitacao, 
           permite_subcontratacao = bl_permite_subcontratacao, tp_fornecimento, 
           descricao_objeto = ds_objeto, vl_estimado_licitacao = vl_licitacao, 
           data_adjudicacao = dt_adjudicacao, vl_homologado, total_concorrentes)
  
  return(info_licitacoes)
}
