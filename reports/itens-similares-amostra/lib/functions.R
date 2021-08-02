library(tidyverse)
library(here)
library(jsonlite)
library(httr)

#' @title Recupera itens similares
#' @param url URL para API do Tá na Mesa
#' @param n_itens Número de itens que serão usados na pesquisa
#' @return Dataframe com os itens similares retornados
#' @example 
#' res <- processa_itens_similares(url = "http://ta-de-pe_backend_1:5000/api/itensContrato/similares", n_itens = 20)
processa_itens_similares <- function(url = "http://ta-de-pe_backend_1:5000/api/itensContrato/similares", 
                                     n_itens = 2000) {
  itens_contrato <- read_csv(here::here("data/bd/info_item_contrato.csv"), 
                             col_types = cols(nr_contrato = col_character()))
  
  set.seed(123)
  itens_contrato_alt <- itens_contrato %>% 
    sample_n(n_itens) %>%
    ungroup() %>% 
    mutate(ds1 = ds_1,
           ds2 = gsub(" ", " & ", ds_2),
           ds3 = gsub(" ", " & ", ds_3)) %>% 
    dplyr::select(id_item_contrato, ds_item, ds1, ds2, ds3, dt_inicio_vigencia, sg_unidade_medida, id_estado) %>% 
    tibble::rowid_to_column(var = "row") %>% 
    mutate(total = nrow(itens_contrato))
  
  itens_similares <- purrr::pmap_df(
    list(
      itens_contrato_alt$id_item_contrato,
      itens_contrato_alt$ds1,
      itens_contrato_alt$ds2,
      itens_contrato_alt$ds3,
      itens_contrato_alt$dt_inicio_vigencia,
      itens_contrato_alt$sg_unidade_medida,
      itens_contrato_alt$id_estado,
      itens_contrato_alt$row,
      itens_contrato_alt$total
    ),
    ~ recupera_itens_similares(..1, ..2, ..3, ..4, ..5, ..6, ..7, ..8, ..9, url = url)
  )
  
  itens_similares_merge <- itens_similares %>% 
    left_join(itens_contrato %>% 
                select(id_item_pesquisado = id_item_contrato,
                       id_contrato_item_pesq = id_contrato,
                       id_licitacao_item_pesq = id_licitacao,
                       ds_item_pesq = ds_item,
                       ds_1_item_pesq = ds_1,
                       ds_2_item_pesq = ds_2,
                       ds_3_item_pesq = ds_3,
                       unidade_medida_item_pesq = sg_unidade_medida,
                       dt_inicio_vigencia_item_pesq = dt_inicio_vigencia,
                       vl_item_pesq = vl_item_contrato,
                       vl_total_item_pesq = vl_total_item_contrato),
              by = c("id_item_pesquisado")) %>% 
    select(dplyr::contains("pesq"), dplyr::everything())
  
  itens_similares_calc <- itens_similares_merge %>% 
    group_by(id_item_pesquisado) %>% 
    mutate(mediana_no_estado = median(vl_item_similar),
           diferenca_com_estado_porcentagem = 100 * (vl_item_pesq - mediana_no_estado) / mediana_no_estado) %>% 
    ungroup()
  
  return(itens_similares_calc)
}

#' @title Recupera itens similares
#' @param ds1 Primeiro atributo de descrição do item
#' @param ds2 Segundo atributo de descrição do item
#' @param ds3 Terceiro atributo de descrição do item
#' @param data Data de contratação do item
#' @param unidade_medida Unidade de medida do item
#' @return Dataframe com os itens similares ao item passado como parâmetro
#' @example res <- recupera_itens_similares("FEIJAO", "FEIJAO & PRETO", "FEIJAO & PRETO & TIPO", "2019-06-01")
recupera_itens_similares <-
  function(item_pesquisa_param, ds1, ds2, ds3, data, unidade_medida, estado, row, total,
           url = "http://ta-de-pe_backend_1:5000/api/itensContrato/similares") {
  print(paste("Recuperando itens similares", ds1, ds2, ds3, data, estado))
  print(paste("Progresso: ", round((row/total)*100, 4), " ", row, "/", total))
  
  req_body = list(termo = c(ds1, ds2, ds3), data = data, unidade = unidade_medida, id_estado = estado)
  
  req <- POST(
    url,
    body = req_body,
    encode = "json"
  )
  
  itens <- tryCatch({
    data <- fromJSON(content(req, "text")) %>%
      as.data.frame()
    
    if (data %>% nrow() == 0) {
      stop(paste("Nenhum item similar retornado (id_item_pesquisado:", item_pesquisa_param,")\n"))
    }
      
    data <- data %>% 
      mutate(id_item_pesquisado = item_pesquisa_param) %>%
      select(id_item_pesquisado,
             id_item_similar = id_item_contrato,
             id_contrato_item_similar = id_contrato,
             id_licitacao_item_similar = id_licitacao,
             vl_item_similar = vl_item_contrato,
             vl_total_item_similar = vl_total_item_contrato,
             ds_item_similar = ds_item,
             unidade_medida_item_similar = sg_unidade_medida,
             dt_inicio_vigencia_item_similar = dt_inicio_vigencia,
             nome_municipio_item_similar = nome_municipio,
             id_estado_item_similar = id_estado,
             similaridade = rel)
  }, error = function(cond) {
    message(cond)
    return(
      tibble(
        id_item_pesquisado = character(),
        id_item_similar = character(),
        id_contrato_item_similar = character(),
        id_licitacao_item_similar = character(),
        vl_item_similar = numeric(),
        vl_total_item_similar = numeric(),
        ds_item_similar = character(),
        unidade_medida_item_similar = character(),
        dt_inicio_vigencia_item_similar = character(),
        nome_municipio_item_similar = character(),
        id_estado_item_similar = numeric(),
        similaridade = numeric()
      )
    )
  })
  
  return(itens)
}
