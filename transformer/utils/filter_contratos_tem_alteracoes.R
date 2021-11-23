library(dplyr)


filtra_contratos_tem_alteracoes <- function(df){
  df <- df %>% filter(tem_alteracoes = "TRUE")
  
  return(df)
}