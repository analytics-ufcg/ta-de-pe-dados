library(tidyverse)
library(here)
library(jsonlite)
library(httr)

#' @title Recupera itens similares
#' @param ds1 Primeiro atributo de descrição do item
#' @param ds2 Segundo atributo de descrição do item
#' @param ds3 Terceiro atributo de descrição do item
#' @param data Data de contratação do item
#' @return Dataframe com os itens similares ao item passado como parâmetro
#' @example res <- recupera_itens_similares("FEIJAO", "FEIJAO & PRETO", "FEIJAO & PRETO & TIPO", "2019-06-01")
processa_itens_similares <- function(url, n_itens = 1000) {
  itens_contrato <- read_csv(here::here("data/bd/info_item_contrato.csv"))
  
  set.seed(123)
  itens_contrato_alt <- itens_contrato %>% 
    sample_n(n_itens) %>% 
    ungroup() %>% 
    mutate(ds1 = ds_1,
           ds2 = gsub(" ", " & ", ds_2),
           ds3 = gsub(" ", " & ", ds_3)) %>% 
    dplyr::select(id_item_contrato, ds_item, ds1, ds2, ds3, dt_inicio_vigencia)
  
  itens_similares <- purrr::pmap_df(
    list(
      itens_contrato_alt$id_item_contrato,
      itens_contrato_alt$ds1,
      itens_contrato_alt$ds2,
      itens_contrato_alt$ds3,
      itens_contrato_alt$dt_inicio_vigencia
    ),
    ~ recupera_itens_similares(..1, ..2, ..3, ..4, ..5, url = url)
  )
  
  return(itens_similares)
}

#' @title Recupera itens similares
#' @param ds1 Primeiro atributo de descrição do item
#' @param ds2 Segundo atributo de descrição do item
#' @param ds3 Terceiro atributo de descrição do item
#' @param data Data de contratação do item
#' @return Dataframe com os itens similares ao item passado como parâmetro
#' @example res <- recupera_itens_similares("FEIJAO", "FEIJAO & PRETO", "FEIJAO & PRETO & TIPO", "2019-06-01")
recupera_itens_similares <-
  function(item_pesquisa_param, ds1, ds2, ds3, data,
           url = "http://ta-na-mesa_backend_1:5000/api/itensContrato/similares") {
  print(paste("Recuperando itens similares", ds1, ds2, ds3, data))
  
  req_body = list(termo = c(ds1, ds2, ds3), data = data)
  
  req <- POST(
    url,
    body = req_body,
    encode = "json"
  )
  
  itens <- tryCatch({
    data <- fromJSON(content(req, "text")) %>%
      as.data.frame() %>%
      mutate(item_pesquisa = item_pesquisa_param) %>%
      select(item_pesquisa,
             id_item_contrato,
             vl_total_item_contrato,
             ds_item,
             rel)
  }, error = function(cond) {
    message(cond)
    return(tribble(~ item_pesquisa, ~ id_item_contrato, ~ vl_total_item_contrato, ~ ds_item, ~ rel))
  })
  
  return(itens)
}
