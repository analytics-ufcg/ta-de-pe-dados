library(magrittr)
source(here::here('code/licitacoes/processa_licitacoes.R'))
source(here::here('code/licitacoes/processa_itens.R'))
source(here::here('code/utils/utils.R'))
source(here::here('code/utils/constants.R'))

help <- "
Usage:
Rscript preprocess_tnm_licitacoes.R <ano>
"

args <- commandArgs(trailingOnly = TRUE)
min_num_args <- 1
if (length(args) < min_num_args) {
  stop(paste("Wrong number of arguments!", help, sep = "\n"))
}

ano <- args[1]

licitacoes_atuais <- tryCatch(
  {
    read_licitacoes("processado")
  },
  error = function(cond) {
    message("Ainda não existem licitações.")
    return(tibble::tibble())
  })


licitacoes_novas <- import_licitacoes_por_ano(ano) %>% 
  generate_id(ano, TABELA_LICITACAO, L_ID)

licitacoes <- tibble::tibble()

if (nrow(licitacoes_atuais) == 0) {
  licitacoes <- licitacoes_novas  
} else {
  licitacoes <- dplyr::bind_rows(licitacoes_atuais, licitacoes_novas) %>% unique()
}

licitacoe_novas_ids <- licitacoes_novas %>% dplyr::select(CD_ORGAO, 
                                               NR_LICITACAO, 
                                               ANO_LICITACAO, 
                                               CD_TIPO_MODALIDADE, 
                                               LICITACAO_ID)

itens_atuais <- tryCatch(
  {
    read_itens("processado")
  },
  error = function(cond) {
    message("Ainda não existem itens")
    return(tibble::tibble())
  })

itens_novos <- import_itens_licitacao_por_ano(ano) %>% 
  rename_duplicate_columns() %>% 
  merge(licitacoe_novas_ids) %>% 
  generate_id(ano, TABELA_ITEM, I_ID)

itens <- tibble::tibble()

if (nrow(itens_atuais) == 0) {
  itens <- itens_novos  
} else {
  itens <- dplyr::bind_rows(itens_atuais, itens_novos) %>% unique()
}


readr::write_csv(licitacoes, paste0("data/licitacoes/processado/licitacao.csv"))

readr::write_csv(itens, paste0("data/licitacoes/processado/item.csv"))
