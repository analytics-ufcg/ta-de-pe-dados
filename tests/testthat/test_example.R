## Este é um exemplo para arquivo de teste

## Todo teste deve ter um contexto
testthat::context("Test Exemplo de teste")

## Em seguida podemos importar os pacotes necessários
library(tidyverse)
library(magrittr)
library(testthat)

## Importe as funções que serão testadas ou usadas como auxílio para o teste
source(here::here("transformer/utils/utils.R"))

## Defina um caso de teste
test_that("Testa add_info_estado", {
  ## Você pode definir as variáveis de entrada aqui
  input_df <- tibble(id = "id-1", nr_licitacao = "nr-1")
  
  ## Você também pode definir o resultado esperado aqui
  expected_df <- tibble(id = "id-1", nr_licitacao = "nr-1", sigla_estado = "PE", id_estado = "99")
  
  ## Você também pode definir o resultado retornado pela função
  output_df <- add_info_estado(input_df, sigla_estado = "PE", id_estado = "99")
  
  ## Enfim teste a função
  expect_equal(output_df, expected_df)
  
  ## Você pode (opcionalmente) testar com mais detalhes para ter um melhor feedback
  expect_equal(output_df$id_estado, expected_df$id_estado)
})
