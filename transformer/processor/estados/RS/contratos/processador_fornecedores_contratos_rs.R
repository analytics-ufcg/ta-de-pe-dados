source(here("transformer/adapter/estados/RS/contratos/adaptador_fornecedores_contratos_rs.R"))

#' Processa dados dos fornecedores do estado do Rio Grande do Sul 
#' para um conjunto de filtros
#' 
#' @param anos Vector de inteiros com anos para captura dos fornecedores
#' 
#' @return Dataframe com informações processadas dos fornecedores
#' 
#' @examples 
#' fornecedores_contratos_rs <- processa_fornecedores_contrato_rs(anos, contratos_rs, compras_rs)
processa_fornecedores_contrato_rs <- function(anos, contratos_rs, compras_rs) {
  fornecedores_contratos_rs <- import_fornecedores(anos) %>%
    adapta_info_fornecedores(contratos_rs, compras_rs) %>% 
    add_info_estado(sigla_estado = "RS", id_estado = "43")
  
  return(fornecedores_contratos_rs)
}