source(here::here("code/utils/read_utils.R"))

#' Processa dados de fornecedores ligados a contratos do estado do Rio Grande do Sul 
#' para um conjunto de anos
#' 
#' @param anos Vector de inteiros com anos para captura dos fornecedores
#' 
#' @return Dataframe com informações dos fornecedores
#' 
#' @examples 
#' fornecedores <- import_fornecedores(c(2018, 2019, 2020))
#' 
import_fornecedores <- function(anos = c(2018, 2019, 2020)) {
  
  fornecedores <- purrr::pmap_dfr(list(anos),
                               ~ import_fornecedores_por_ano(..1)
  )
  
  return(fornecedores)
}

#' Importa dados de fornecedores ligados a contratos em um ano específico para o 
#' estado do Rio Grande do Sul
#' 
#' @param ano Inteiro com o ano para recuperação dos fornecedores dos contratos
#'
#' @return Dataframe com informações dos fornecedores
#'   
#' @examples 
#' fornecedores <- import_fornecedores_por_ano()
#' 
import_fornecedores_por_ano <- function(ano = 2019) {
  message(paste0("Importando fornecedores do ano ", ano))
  fornecedores <- read_fornecedores_contratos(ano)
  
  return(fornecedores)
}

#' Processa dados para tabela de informações dos fornecedores no RS
#' 
#' @param fornecedores_df Dataframe de fornecedores para padronização
#'
#' @return Dataframe com informações dos fornecedores
#'   
#' @examples 
#' fornecedores <- processa_info_fornecedores(fornecedores_df)
#' 
#' Chave primária: 
#' (nr_documento)
processa_info_fornecedores <- function(fornecedores_df) {
  
  info_fornecedores <- fornecedores_df %>%
    janitor::clean_names() %>% 
    dplyr::arrange(nm_pessoa) %>% 
    dplyr::group_by(nr_documento) %>% 
    dplyr::summarise(nm_pessoa = dplyr::first(nm_pessoa),
                     tp_pessoa = dplyr::first(tp_pessoa)) %>% 
    dplyr::ungroup()
}
