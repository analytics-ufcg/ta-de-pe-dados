source(here::here("code/utils/read_utils.R"))

#' Processa dados de itens dos contratos do estado do Rio Grande do Sul para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos itens dos contratos
#' 
#' @return Dataframe com informações dos itens dos contratos
#' 
#' @examples 
#' itens_contrato <- import_itens_contrato(c(2017, 2018, 2019))
#' 
import_itens_contrato <- function(anos = c(2017, 2018, 2019)) {
  
  itens_contrato <- purrr::pmap_dfr(list(anos),
                              ~ import_itens_contrato_por_ano(..1)
  )
  
  return(itens_contrato)
}

#' Importa dados de itens dos contratos em um ano específico para o estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação dos itens dos contratos
#'
#' @return Dataframe com informações dos itens dos contratos
#'   
#' @examples 
#' itens_contrato <- import_itens_contrato_por_ano(2019)
#' 
import_itens_contrato_por_ano <- function(ano = 2019) {
  message(paste0("Importando itens de contrato do ano ", ano))
  itens_contrato <- read_itens_contrato(ano)
  
  return(itens_contrato)
}

#' Processa dados para a tabela de informações dos itens dos contratos de merenda
#' 
#' @param itens_contrato_df Dataframe de itens de contrato
#'
#' @return Dataframe com informações dos itens dos contratos de merenda
#'   
#' @examples 
#' info_item_contrato <- processa_info_item_contrato(itens_contrato_df)
#'
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato,
#' nr_lote, nr_item)
processa_info_item_contrato <- function(itens_contrato_df) {
  
  info_item_contrato <- itens_contrato_df %>% 
    distinct(CD_ORGAO, NR_LICITACAO, ANO_LICITACAO, CD_TIPO_MODALIDADE, NR_CONTRATO, 
             ANO_CONTRATO, TP_INSTRUMENTO, NR_LOTE, NR_ITEM, .keep_all=TRUE) %>%
    rename(QT_ITENS_CONTRATO = QT_ITENS,
           VL_ITEM_CONTRATO = VL_ITEM,
           VL_TOTAL_ITEM_CONTRATO = VL_TOTAL_ITEM) %>%
    select(-c(PC_BDI, PC_ENCARGOS_SOCIAIS)) %>%
    clean_names() %>%
    select(id_orgao = cd_orgao, nr_lote, nr_licitacao, ano_licitacao, cd_tipo_modalidade, nr_contrato, 
           ano_contrato, tp_instrumento_contrato = tp_instrumento, nr_item, qt_itens_contrato, 
           vl_item_contrato, vl_total_item_contrato)
  

  
  return(info_item_contrato)
}

#' Gera ids das categorias dos itens dos contratos de merenda de acordo com sua descrição
#' 
#' @param info_item_contrato Dataframe de itens de contrato
#'
#' @return Dataframe com informações dos itens dos contratos de merenda com id da categoria
#'   
#' @examples 
#' info_item_contrato <- create_categoria(info_item_contrato)
#'
#' Chave primária: 
#' (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato,
#' nr_lote, nr_item)
create_categoria <- function(info_item_contrato) {
  categorias <- info_item_contrato %>% 
    select(ds_item) %>% 
    ungroup() %>% 
    mutate(ds_item =str_squish(str_to_lower(gsub("[[:punct:]]", "", ds_item )))) %>% 
    mutate(ds_item = iconv(ds_item, from="UTF-8", to="ASCII//TRANSLIT")) %>%
    distinct()
  
  categorias$categoria <- seq.int(nrow(categorias))
  
  itens_com_categorias <- info_item_contrato %>% 
    mutate(ds_item =str_squish(str_to_lower(gsub("[[:punct:]]", "", ds_item )))) %>% 
    mutate(ds_item = iconv(ds_item, from="UTF-8", to="ASCII//TRANSLIT")) %>%
    left_join(categorias) %>%
    select(id_item_contrato, categoria)
  
  info_item_contrato %<>% left_join(itens_com_categorias) %>% 
    mutate(language = "portuguese")
}
