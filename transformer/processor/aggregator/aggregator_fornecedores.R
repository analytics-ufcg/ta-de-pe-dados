library(tidyverse)
library(magrittr)
library(here)
library(futile.logger)

source(here::here("transformer/utils/utils.R"))
source(here::here("transformer/utils/join_utils.R"))
source(here::here("transformer/utils/constants.R"))

source(here::here("transformer/processor/estados/RS/contratos/processador_fornecedores_contratos_rs.R"))
source(here::here("transformer/processor/estados/PE/contratos/processador_fornecedores_contratos_pe.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_eventos_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_lotes_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_itens_contratos_rs.R"))
source(here::here("transformer/processor/estados/RS/contratos/processador_compras_rs.R"))
source(here::here("transformer/processor/estados/RS/licitacoes/processador_itens_licitacoes_rs.R"))
source(here::here("transformer/processor/estados/Federal/contratos/processador_compras_federal.R"))
source(here::here("transformer/processor/estados/Federal/contratos/processador_fornecedores_contratos_federal.R"))

#' Agrupa dados de fornecedores monitorados pelo Tá de pé
#'
#' @param anos Array com os anos para processamento.
#' @param administracao Array com a lista de estados/administrações para processar.
#' @param info_contratos Dados agregados de contratos e compras
#' @return Dataframe com os fornecedores agregados e prontos para ir para o BD.
#' 
#' @examples 
#' contratos_agregados <- 
#' aggregator_fornecedores(c(2020), c("PE", "RS"), info_contratos)
aggregator_fornecedores <- function(anos, administracao = c("PE", "RS"), info_contratos) {
  
  flog.info("#### Processando agregador de fornecedores..")
  
  if ("RS" %in% administracao) {
    fornecedores_contratos_rs <- tryCatch({
      flog.info("# processando fornecedores do RS...")
      
      flog.info("licitações encerradas...")
      licitacoes_encerradas_rs <- processa_eventos_licitacoes_rs(anos)
      
      flog.info("lotes de licitação...")
      lotes_licitacoes_rs <- processa_lotes_licitacoes_rs(anos)
      
      flog.info("preparando dados de itens de licitação e contratos...")
      itens_contrato <- processa_itens_contrato_rs(anos)
      itens_licitacao <- processa_itens_licitacoes_renamed_columns_rs()
      
      flog.info("processando compras...")
      compras_rs <- processa_compras_rs(anos, licitacoes_encerradas_rs, lotes_licitacoes_rs, itens_licitacao, itens_contrato)
      
      flog.info("processando contratos do RS...")
      contratos_rs <- processa_contratos_rs(anos)

      processa_fornecedores_contrato_rs(anos, contratos_rs, compras_rs)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de fornecedores do RS")
      flog.error(e)
      return(tibble())
    })
  } else {
    fornecedores_contratos_rs <- tibble()
  }
  
  if ("PE" %in% administracao) {
    fornecedores_contratos_pe <- tryCatch({
      flog.info("# processando fornecedores do PE...")
      
      flog.info("processando contratos de PE...")
      contratos_pe <- processa_contratos_pe()
      
      processa_fornecedores_contratos_pe(contratos_pe)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de fornecedores do PE")
      flog.error(e)
      return(tibble())
    })
  } else {
    fornecedores_contratos_pe <- tibble()
  }

  if ("BR" %in% administracao) {
    fornecedores_contratos_federal <- tryCatch({
      flog.info("# processando fornecedores do Governo Federal...")
      
      flog.info("processando compras/contratos do Governo Federal...")
      compras_federais <- processa_compras_federal()
      
      processa_fornecedores_contratos_federal(compras_federais)
    }, error = function(e) {
      flog.error("Ocorreu um erro ao processar os dados de fornecedores do Governo Federal")
      flog.error(e)
      return(tibble())
    })
  } else {
    fornecedores_contratos_federal <- tibble()
  }
  
  info_fornecedores_contratos <- bind_rows(fornecedores_contratos_rs,
                                           fornecedores_contratos_pe,
                                           fornecedores_contratos_federal)
  
  if (nrow(info_fornecedores_contratos) == 0) {
    flog.warn("Nenhum dado de fornecedor para agregar!")
    return(tibble())
  }
  
  info_fornecedores_contratos <- info_fornecedores_contratos %>%
    join_contratos_e_fornecedores(info_contratos %>%
                                    dplyr::select(nr_documento_contratado)) %>%
    dplyr::distinct(nr_documento, id_estado, .keep_all = TRUE) %>% 
    dplyr::group_by(nr_documento) %>% 
    dplyr::mutate(total_de_contratos = sum(total_de_contratos, na.rm = T),
                  data_primeiro_contrato = min(data_primeiro_contrato, na.rm = T)) %>% 
    dplyr::distinct(nr_documento, .keep_all = TRUE) %>%
    dplyr::select(nr_documento, id_estado, nm_pessoa, tp_pessoa, total_de_contratos, data_primeiro_contrato)

  return(info_fornecedores_contratos)
}
