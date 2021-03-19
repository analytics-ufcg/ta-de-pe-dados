library(tidyverse)
library(here)

#' Cria dataframe com tipos de modalidade de licitações
#' 
#' @examples 
#' tipos_modalidade_licitacoes <- adapta_tipos_modalidade_licitacoes()
#' 
adapta_tipos_modalidade_licitacoes <- function() {
  tipo_modalidade_licitacao <- data.frame(cd_tipo_modalidade = c("CPP", "CHP", "CPC", "CNC", "CNS", "CNV", "ESE", "EST", 
                                                      "LEE", "LEI", "MAI", "PRE", "PRP", "PRD", "PDE", "PRI", 
                                                      "RDE", "RDC", "RPO", "RIN", "TMP"),
                               tipo_modalidade_licitacao = c("Chamada Pública-PNAE:  Programa Nacional de Alimentação Escolar", 
                                                             "Chamamento Público", "Chamamento Público Credenciamento", "Concorrência", 
                                                             "Concurso", "Convite", "Lei 13.303/2016 Eletrônico", "Lei 13.303/2016 Presencial", 
                                                             "Leilão Eletrônico", "Leilão Presencial", "Manifestação de Interesse", 
                                                             "Pregão Eletrônico", "Pregão Presencial", "Processo de Dispensa", 
                                                             "Processo de Dispensa Eletrônica", "Processo de Inexigibilidade", 
                                                             "Regime Diferenciado de Contratação (Lei nº 12.462) - Eletrônico", 
                                                             "Regime Diferenciado de Contratação (Lei nº 12.462) - Presencial", 
                                                             "Registro de Preço de Outro Órgão", "Regras Internacionais", "Tomada de Preços"),
                               stringsAsFactors = FALSE)
  
  return(tipo_modalidade_licitacao)
}
