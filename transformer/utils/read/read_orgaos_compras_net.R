library(tidyverse)
library(here)

get_compras_net_unid_gestoras <- function() {
  lista <- readxl::read_xlsx(here("data/dados_federais/lista_uasgs.xlsx"))
  
  unidades_gestoras <- lista %>% 
    filter(SISG == "S") %>% 
    select(codigo_ug = `CÓDIGO DA UASG`, nome_ug = `NOME DA UASG`)
  
  return(unidades_gestoras)
}
