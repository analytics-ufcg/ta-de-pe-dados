library(tidyverse)
library(here)

#' Cria dataframe com tipos de licitações
#' 
#' @examples 
#' tipos_licitacoes <- adapta_tipos_licitacoes()
#' 
adapta_tipos_licitacoes <- function() {
  tipo_licitacao <- data.frame(tp_licitacao = c("MCA", "MDE", "MLO", "MOO", 
                                                "MOP", "MOQ", "MOT", "MPP",
                                                "MPR", "MRE", "MTC", "MTX", "MTO",
                                                "MTT", "MVT", "NSA", "TPR"),
                               tipo_licitacao = c("Melhor Conteúdo Artístico", "Maior Desconto", "Maior Lance ou Oferta" , "Maior Oferta de Outorga", 
                                                  "Maior Oferta de Preço", "Maior Oferta de Outorga após Qualificação das Propostas Técnicas", 
                                                  "Maior Oferta de Outorga e Melhor Técnica" , "Melhor Proposta Técnica com Preço fixado no Edital",
                                                  "Menor Preço" , "Maior Retorno Econômico" , "Melhor Técnica" , "Menor Taxa" , 
                                                  "Menor Valor da Tarifa e Maior Oferta de Outorga" , "Menor Valor da Tarifa e Melhor Técnica",
                                                  "Menor Valor da Tarifa", "Não se Aplica" , "Técnica e Preço"),
                               stringsAsFactors = FALSE)
  
  return(tipo_licitacao)
} 
