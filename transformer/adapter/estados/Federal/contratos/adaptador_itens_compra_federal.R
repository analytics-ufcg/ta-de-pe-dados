source(here::here("transformer/utils/read/read_itens_empenhos_federais.R"))
source(here::here("transformer/utils/read/read_historico_itens_federais.R"))

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

#' Importa dados do histórico de itens das compras do governo Federal
#'
#' @return Dataframe com informações do histórico de itens das compras do governo Federal (sem filtro)
#'
#' @examples
#' historico_itens_federais <- import_historico_itens_compras_federais()
#'
import_historico_itens_compras_federais <- function() {
  message("Importando históricos de itens das compras do governo Federal")
  source(here::here("transformer/utils/bd_constants.R"))
  
  historico_itens_federais <-
    read_historico_itens_federais(POSTGRES_HOST,
                                       POSTGRES_USER,
                                       POSTGRES_DB,
                                       POSTGRES_PORT,
                                       POSTGRES_PASSWORD)
  
  return(historico_itens_federais)
}

#' Atualiza preço dos itens federais com base no histórico de itens
#'
#' @param itens_compra_federal_df Dataframe de itens de empenho para adaptação. Pode ser gerado a partir da função import_itens_compras_federais()
#' @param historico_itens_federais Dataframe do histórico de itens de empenhos federais para adaptação. 
#' Pode ser gerado a partir da função import_historico_itens_compras_federais()
#'
#' @return Dataframe com as mesmas colunas do dataframe de itens federais (itens_compra_federal_df) mas com a coluna vl_item_contrato
#' com o preço atualizado e a coluna vl_item_contrato_original com o valor original encontrado para o item
#'
#' @examples
#' itens_compras_BR <- atualiza_preco_itens_federais(itens_compras_BR, historico_itens_federais)
atualiza_preco_itens_federais <- function(itens_compra_federal_df, historico_itens_federais) {
  ## Decisões
  # Foram excluídas linhas do histórico em que houve anulação
  
  # O preço unitário do item é a média do valor unitário nas ocorrências de INCLUSAO e REFORCO
  # A quantidade do item é a soma da quantidade nas ocorrências de INCLUSAO e REFORCO
  
  # O valor total do item é o valor informado pela tabela de itens federais no campo (valor atual).
  # Não necessariamente o valor atual do item corresponde ao valor untiário * quantidade (pelo fator anulações)
  # Nem sempre o valor atual do item bate com o valor no Portal (possivelmente inconsistência nos dados (exemplo abaixo))
  
  # Há casos de inconsistência em que a operação parece estar repetida (160109000012021NE000034, 6)
    
  historico_merge <- historico_itens_federais %>% 
    inner_join(itens_compra_federal_df %>% 
                 select(codigo_empenho, sequencial, valor_atual), 
               by = c("codigo_empenho", "sequencial")) %>% 
    mutate(quantidade = if_else(tipo_operacao == 'ANULACAO', -(quantidade), quantidade)) %>% 
    ungroup() %>% 
    mutate(valor_original = valor_atual) %>% 
    mutate(valor_total = valor_unitario * quantidade) %>% 
    group_by(codigo_empenho, sequencial) %>% 
    summarise(
      quantidade = sum(quantidade),
      valor_total = sum(valor_total),
      valor_original = first(valor_original),
      .groups = 'drop'
    ) %>%
    mutate(quantidade = if_else((quantidade == 0 & valor_total > 0), 1, quantidade)) %>%
    mutate(valor_unitario = valor_total / quantidade) %>% 
    mutate(valor_nan = is.nan(valor_unitario),
           quantidade_negativa = quantidade < 0,
           quantidade_c_valor_zero = quantidade > 0 && valor_total == 0,
           valor_infinito = is.infinite(valor_unitario),
           valor_negativo = valor_unitario < 0,
           valor_sem_quantidade = quantidade <= 0  && valor_unitario > 0,
    ) %>% 
    mutate(tem_inconsistencia = if_else(!(valor_nan)  
                                        &(quantidade_negativa
                                        | quantidade_c_valor_zero
                                        | valor_infinito
                                        | valor_negativo
                                        | valor_sem_quantidade), TRUE, FALSE)
    )
  
  itens_atualizados <- itens_compra_federal_df %>% 
    left_join(historico_merge, 
              by = c("codigo_empenho", "sequencial")) %>% 
    mutate(quantidade = if_else(!is.na(quantidade.y), quantidade.y, as.numeric(quantidade.x)),
           valor_unitario = if_else(!is.na(valor_unitario.y), valor_unitario.y, valor_unitario.x),
           valor_total = if_else(!is.na(valor_total.y), valor_total.y, valor_total.x)) %>% 
    select(-c(quantidade.x, quantidade.y,
              valor_unitario.x, valor_unitario.y,
              valor_total.x, valor_total.y))
  
  return(itens_atualizados)
}

#' Processa dados para tabela de informações dos itens das compras do governo federal
#' As compras do governo federal são extraídas dos empenhos (notas de empenho)
#'
#' @param itens_compra_federal_df Dataframe de itens de empenho para adaptação. Pode ser gerado a partir da função import_itens_compras_federais()
#' @param empenhos_relacionados_df Dataframe adaptado que liga empenhos à licitações. Pode ser gerado a partir da função processa_compras_federal()
#' @param historico_itens_federais Dataframe do histórico de itens de empenhos federais para adaptação. 
#' Pode ser gerado a partir da função import_historico_itens_compras_federais()
#' @param filtro Tipo de filtro para aplicação nos dados. Apenas 'covid' está disponível.
#'
#' @return Dataframe com informações dos itens das compras do governo federal
#'
#' @examples
#' itens_compras_BR <- adapta_info_itens_compras_federal(itens_compra_federal_df, empenhos_relacionados_df, filtro)
adapta_info_itens_compras_federal <- function(itens_compra_federal_df, empenhos_relacionados_df, historico_itens_federais, filtro) {
  if (filtro == 'covid') {
    flog.info("Aplicando filtro de covid para as compras do Governo Federal")
  } else if (filtro == 'merenda') {
    flog.info("Filtro de merenda não está pronto para o Gov Federal")
    return(tibble())
  } else {
    stop("Tipo de filtro não definido. É possível filtrar pelos tipos 'merenda' ou 'covid")
  }
  
  itens_compra_federal_df <- atualiza_preco_itens_federais(itens_compra_federal_df, historico_itens_federais)
  
  info_itens_compras_federal <- itens_compra_federal_df %>%
    rowid_to_column(var='nr_item') %>% 
    janitor::clean_names() %>%
    mutate(ano_licitacao = NA_integer_,
           nr_lote = NA_integer_,
           valor_total = if_else(!is.na(valor_atual), valor_atual, valor_total),
           tem_inconsistencia = if_else(!is.na(tem_inconsistencia), tem_inconsistencia, F)) %>%
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
    dplyr::mutate(ds_tidy = str_remove_all(descricao, '^[0-9]+,[0-9]+ [A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ\'\\.]* +([0-9]+,[0-9]+ [A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ\'\\.]* +)?')) %>%
    dplyr::mutate(ds_tidy = str_remove_all(ds_tidy, "^( )*([$]|-|_|,|@|[.]|'|#|])*( )?")) %>%
    dplyr::mutate(ds_tidy = str_remove_all(ds_tidy, "\\((( )?([0-9]+|U(N)?|ITEM [0-9]+( DO TR)?)|([0-9]{2,}\\/[0-9]{2,}\\/[0-9]{4,}#[0-9]+))\\)( )?")) %>%
    dplyr::mutate(ds_tidy = str_replace_all(ds_tidy, '((\r|\n|\t)|( ){2,})+', ' ')) %>%
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
      origem_valor,
      tem_inconsistencia
    )
  
  return(info_itens_compras_federal)
}
