source(here("transformer/adapter/estados/PE/contratos/adaptador_itens_contratos_pe.R"))

#' Processa dados dos itens do estado de Pernambuco 
#' 
#' @return Dataframe com informações processadas dos itens
#' 
#' @examples 
#' itens_contratos_pe <- processa_itens_contrato_pe(contratos_pe_df, licitacoes_pe_df)
processa_itens_contrato_pe <- function(contratos_pe_df, licitacoes_pe_df) {
  itens_contratos_pe <- import_itens_contrato_pe() %>%
    adapta_info_itens_contratos_pe(contratos_pe_df, licitacoes_pe_df) %>%
    filter(!is.na(cd_orgao)) %>% 
    add_info_estado(sigla_estado = "PE", id_estado = "26") 
  
  return(itens_contratos_pe)
}