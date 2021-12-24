library(tidyverse)
source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/adapter/estados/PE/licitacoes/adaptador_licitacoes_pe.R"))
source(here::here("transformer/processor/estados/PE/contratos/processador_contratos_pe.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_contratos_rs.R"))
source(here::here("transformer/processor/estados/Federal/contratos/processador_compras_federal.R"))
source(here::here("transformer/processor/estados/Federal/licitacoes/processador_licitacoes_federal.R"))

#' Agrupa todos os contratos dos estados disponíveis na plataforma Tá de pé
#' 
#' @param anos Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @param estados Array com os estados para considerar nos contratos
#' @return Dataframe os contratos agregados
#' 
#' @examples 
#' contratos <- agrega_contratos(c(2018, 2019, 2020), c("RS", "PE", "BR"))
agrega_contratos <- function(anos, estados = c("RS", "PE", "BR")) {
  
  if ("RS" %in% estados) {
    contratos_rs <- tryCatch({
      flog.info("# processando contratos do RS...")
      processa_contratos_rs(anos)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de contratos do RS")
      flog.error(e)
      return(tibble())
    })
  } else {
    contratos_rs <- tibble()
  }
  
  if ("PE" %in% estados) {
    contratos_pe <- tryCatch({
      flog.info("# processando contratos do PE...")
      contratos_raw <- processa_contratos_pe()
      licitacoes_raw <- import_licitacoes_pe() %>%
        janitor::clean_names() %>% 
        select(
          nr_licitacao = codigo_pl,
          cd_orgao = codigo_ug,
          ano_licitacao = ano_processo,
          cd_tipo_modalidade = codigo_modalidade
        ) %>%
        add_info_estado("PE", "26") %>% 
        distinct(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, id_estado)
      
      contratos_merge <- contratos_raw %>% 
        dplyr::inner_join(licitacoes_raw, by = c("cd_orgao", "nr_licitacao", "id_estado"))
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de contratos do PE")
      flog.error(e)
      return(tibble())
    })
  } else {
    contratos_pe <- tibble()
  }
  
  if ("BR" %in% estados) {
    contratos_federais <- tryCatch({
      flog.info("# processando contratos do BR...")
      compras_raw <- processa_compras_federal()
      licitacoes_raw <- processa_licitacoes_federal()
      
      compras_federais <- compras_raw %>%
        dplyr::left_join(
          licitacoes_raw %>%
            dplyr::select(cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, id_estado) %>% 
            filter(id_estado == "99"),
          by = c(
            "cd_orgao_lic" = "cd_orgao",
            "nr_licitacao",
            "cd_tipo_modalidade",
            "id_estado"
          )
        )
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de contratos do BR")
      flog.error(e)
      return(tibble())
    })
  } else {
    contratos_federais <- tibble()
  }
  
  if (nrow(contratos_rs) == 0 && nrow(contratos_pe) == 0 && nrow(contratos_federais) == 0) {
    flog.warn("Nenhum dado de contrato para agregar")
    return(tibble())
  }
  
  todos_contratos <- bind_rows(contratos_rs, contratos_pe, contratos_federais) %>%
    select(id_estado, cd_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, 
           nr_contrato, ano_contrato, tp_instrumento_contrato,
           nm_orgao, nr_documento_contratado, dt_inicio_vigencia, vl_contrato, descricao_objeto_contrato)
  
  return(todos_contratos)
}
