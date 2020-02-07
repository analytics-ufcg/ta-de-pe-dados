library(tidyverse)
library(here)

#' Cria dataframe com tipos de alteração de contrato
#' 
#' @examples 
#' tipo_instrumento_contrato <- processa_tipos_alteracao_contrato()
#' 
processa_tipos_alteracao_contrato <- function() {
  tipo_operacao_alteracao <- data.frame( cd_tipo_operacao = c("ACA", "ACC", "ADO", "AGF", "ANR",
                                                              "AVI", "MFP", "MMF", "MPE", "MRE",
                                                              "OUT", "PPC", "REF", "REN", "RJP",
                                                              "RVP", "RVS", "SGE"),
                                         tipo_operacao_alteracao = c( "Acréscimo de Valor por Aumento de Quantitativo",
                                                                      "Alteração ou cessão de contratado", 
                                                                      "Alteração de Dotação Orçamentária",
                                                                      "Alteração do gestor / fiscal",
                                                                      "Alteração da Natureza ou da Razão Social do Fornecedor",
                                                                      "Acréscimo de valor por inclusão de Itens novos",
                                                                      "Modificação da Forma de Pagamento",
                                                                      "Modificação do Modo de Fornecimento",
                                                                      "Modificação do Projeto ou das Especificações Técnicas",
                                                                      "Modificação do Regime de Execução",
                                                                      "Outros",
                                                                      "Prorrogação Prazo Contratual",
                                                                      "Reequilíbrio Econômico-Financeiro",
                                                                      "Renovação Contratual",
                                                                      "Reajustamento de Preços",
                                                                      "Redução de Valor por Supressão de Itens",
                                                                      "Redução de Valor por Supressão de Quantitativo",
                                                                      "Substituição de garantia de execução"),
                                         stringsAsFactors = FALSE)
  
  return(tipo_operacao_alteracao)
} 
