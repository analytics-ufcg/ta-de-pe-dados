library(tidyverse)
library(magrittr)
library(futile.logger)

#' Cria dataframe com os tipos de alertas
#' 
#' @return Dataframe com tipos de alertas
#' 
#' @examples 
#' alertas <- create_tipo_alertas()
create_tipo_alertas <- function() {
  id_tipo <- c(1, 2, 3, 4)
  titulo <- c("Contratado logo após a abertura",
              "Produtos atípicos",
              "Contratado inidôneo",
              "Faturamento alto")
  descricao <- c("Contratos assinados com menos de 30 dias após abertura da empresa",
              "Venda de produto incomum para a atividade econômica informada da empresa",
              "Contratos assinados com empresas sancionadas ou condenadas",
              "Empresa vende acima do faturamento legal permitido à sua categoria")
  
  tipos_alertas <- data.frame(id_tipo, titulo, descricao)
  flog.info(str_glue("{tipos_alertas %>% nrow()} tipos de alertas gerados"))
  
  return(tipos_alertas)
}
