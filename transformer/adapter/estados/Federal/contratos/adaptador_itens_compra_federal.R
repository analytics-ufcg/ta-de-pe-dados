source(here::here("transformer/utils/read/read_itens_empenhos_federais.R"))

#' Importa dados de itens das compras do governo Federal
#'
#' @return Dataframe com informações dos itens da compras
#'
#' @examples
#' import_itens_compras_federais <- import_itens_compras_federais()
#'
import_itens_compras_federais <- function() {
  message("Importando itens das compras do governo Federal")
  source(here::here("transformer/utils/bd_constants.R"))
  
  itens_compra_federais <-
    read_itens_empenhos_federais_covid(POSTGRES_HOST,
                                       POSTGRES_USER,
                                       POSTGRES_DB,
                                       POSTGRES_PORT,
                                       POSTGRES_PASSWORD)
  
  return(itens_compra_federais)
}

#' Processa dados para tabela de informações dos itens das compras do governo federal
#' As compras do governo federal são extraídas dos empenhos (notas de empenho)
#'
#' @param itens_compra_federal_df Dataframe de itens de empenho para adaptação. Pode ser gerado a partir da função import_itens_compras_federais()
#' @param empenhos_relacionados_df Dataframe adaptado que liga empenhos à licitações. Pode ser gerado a partir da função processa_compras_federal()
#' @param filtro Tipo de filtro para aplicação nos dados. Apenas 'covid' está disponível.
#'
#' @return Dataframe com informações dos itens das compras do governo federal
#'
#' @examples
#' itens_compras_BR <- adapta_info_itens_compras_federal(itens_compra_federal_df, empenhos_relacionados_df, filtro)
adapta_info_itens_compras_federal <- function(itens_compra_federal_df, empenhos_relacionados_df, filtro) {
  if (filtro == 'covid') {
    flog.info("Aplicando filtro de covid para as compras do Governo Federal")
  } else if (filtro == 'merenda') {
    flog.info("Filtro de merenda não está pronto para o Gov Federal")
    return(tibble())
  } else {
    stop("Tipo de filtro não definido. É possível filtrar pelos tipos 'merenda' ou 'covid")
  }
  
  info_itens_compras_federal <- itens_compra_federal_df %>%
    rowid_to_column(var='nr_item') %>% 
    janitor::clean_names() %>%
    mutate(ano_licitacao = NA_integer_,
           nr_lote = NA_integer_) %>%
    rename(
      codigo_contrato = codigo_empenho,
      qt_itens_contrato = quantidade,
      vl_item_contrato = valor_unitario,
      vl_total_item_contrato = valor_total,
      sg_unidade_medida = unidade,
      cd_tipo_modalidade = codigo_modalidade_aplicacao
    ) %>%
    left_join(
      empenhos_relacionados_df %>% select(
        codigo_contrato,
        cd_orgao,
        nr_licitacao,
        nr_contrato,
        ano_contrato,
        tp_instrumento_contrato
      ),
      by = c("codigo_contrato")
    ) %>%
    dplyr::mutate(origem_valor = 'empenho')  %>%
    mutate(
      cd_tipo_modalidade = as.character(cd_tipo_modalidade),
      nr_item = as.integer(nr_item),
      qt_itens_contrato = as.double(qt_itens_contrato),
      vl_item_contrato = as.double(vl_item_contrato),
      vl_total_item_contrato = as.double(vl_total_item_contrato)
    ) %>%
    dplyr::mutate(item = str_remove_all(item, "^'([[:alpha:]]*(.)*?)*'[[:blank:]]*")) %>%
    dplyr::mutate(ds_tidy = str_remove_all(descricao, "^[0-9]*(,|.)[0-9]* ?((?i)(unidade(s de)?|ML|L(i)?|quilograma|par|galão|embalagem( [0-9]+,[0-9]+ )?|caixa ([0-9]+,[0-9]+ UN(D)?)?|teste|un.|saco|lata|frasco(-ampola)?|pacote|milheiro|metro c.bico|conjunto|jogo|L|peça( [0-9]+,[0-9]+ M)?))?[[:space:]|[:blank:]]*([0-9]*,[0-9]* ?(UN|L))?")) %>% 
    dplyr::mutate(ds_tidy = str_remove_all(ds_tidy, "^'([[:alpha:]]*(.)*?)*'[[:blank:]]*")) %>%
    dplyr::mutate(ds_tidy = str_remove_all(ds_tidy, "^[$|[:punct:]]*( )?")) %>%
    dplyr::mutate(ds_item = case_when(
      !is.na(item) ~ if_else(tolower(item) == tolower(descricao_restante), 
                             str_glue("{item} {marca}"), 
                             str_glue("{item} {marca} {descricao_restante}")),
      TRUE ~ ds_tidy
    )) %>% 
    select(
      nr_item,
      codigo_contrato,
      ds_item,
      qt_itens_contrato,
      sg_unidade_medida,
      vl_item_contrato,
      vl_total_item_contrato,
      nr_lote,
      cd_orgao,
      nr_licitacao,
      nr_contrato,
      ano_contrato,
      tp_instrumento_contrato,
      ano_licitacao,
      cd_tipo_modalidade,
      origem_valor
    )
  
  return(info_itens_compras_federal)
}
