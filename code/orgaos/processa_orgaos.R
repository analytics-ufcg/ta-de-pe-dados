#' Cria dataframe com informações dos orgãos participantes de licitações
#' 
#' @examples 
#' municipios <- processa_info_orgaos()
#' 
processa_info_orgaos <- function(licitacoes_df) {
  
  info_orgaos <- licitacoes_df %>%
    janitor::clean_names() %>% 
    dplyr::distinct(nm_orgao, cd_orgao) %>%
    dplyr::mutate(id_estado = "43") %>% 
    dplyr:: select(orgao_id = cd_orgao, id_estado, nm_orgao)
  
  return(info_orgaos)
}
