library(tidyverse)

#' Cria dataframe com informações dos Estados com o código do IBGE
#' 
#' @examples 
#' estados <- processa_info_estados()
#' 
processa_info_estados <- function() {
  info_estados <- tibble(id_estado = c(11:17, 21:29, 31:33,35, 41:43, 50:53),
                         nm_estado = c("Rondônia", "Acre", "Amazonas", "Roraima", "Pará","Amapá", "Tocantins",
                                       "Maranhão", "Piauí", "Ceará", "Rio Grande do Norte", "Paraíba", "Pernambuco", 
                                       "Alagoas", "Sergipe", "Bahia", "Minas Gerais",  "Espírito Santo", 
                                       "Rio de Janeiro","São Paulo", "Paraná", "Santa Catarina", "Rio Grande do Sul", 
                                       "Mato Grosso do Sul", "Mato Grosso", "Goiás", "Distrito Federal"),
                         sg_estado = c("RO", "AC", "AM", "RR", "PA", "AP", "TO", "MA", "PI", "CE", "RN", "PB", 
                                       "PE", "AL", "SE", "BA" , "MG", "ES" , "RJ", "SP", "PR", "SC", "RS", 
                                       "MS", "MT", "GO", "DF")) %>% 
    mutate(id_estado = as.character(id_estado))
  
  return(info_estados)
} 
