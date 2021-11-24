testthat::context("Test Adaptador itens federais")

library(tidyverse)
library(magrittr)
library(testthat)

source(here::here("transformer/adapter/estados/Federal/contratos/adaptador_itens_compra_federal.R"))

test_that("Testa atualiza_preco_itens_federais", {
  ## Você pode definir as variáveis de entrada aqui
  itens_compra_federal_df <- read_csv(here::here("tests/testthat/data/historico_itens/itens_compra_federal_df.csv"))
  historico_itens_federais <- read_csv(here::here("tests/testthat/data/historico_itens/historico_itens_federais.csv"))
  
  expected_df <- read_csv(here::here("tests/testthat/data/historico_itens/expected_output.csv"))
  
  output_df <- atualiza_preco_itens_federais(itens_compra_federal_df, historico_itens_federais) %>% 
    select(codigo_empenho, sequencial, quantidade, valor_unitario, valor_atual)
  
  expect_true(all_equal(
    output_df %>% filter(codigo_empenho == "550027000012021NE000001"),
    expected_df %>% filter(codigo_empenho == "550027000012021NE000001")
  ),
  label = "Compra do auxílio emergencial processada")
  
  expect_true(all_equal(
    output_df %>% filter(codigo_empenho == "250005000012021NE000454"),
    expected_df %>% filter(codigo_empenho == "250005000012021NE000454")
  ),
  label = "Compra de doses da vacina processada")
  
  expect_true(all_equal(
    output_df %>% filter(codigo_empenho == "120039000012021NE000347"),
    expected_df %>% filter(codigo_empenho == "120039000012021NE000347")
  ),
  label = "Compra com inclusao, reforco e anulacao")
  
  ## Linhas duplicadas na tabela do histórico de itens geram inconsistências
  expect_true(all_equal(
    output_df %>% filter(codigo_empenho == "170596000012021NE000221"),
    expected_df %>% filter(codigo_empenho == "170596000012021NE000221")
  ),
  label = "Compra com inclusao, reforco e anulacao")
  
  expect_true(all_equal(
    output_df %>% filter(codigo_empenho == "250110000012021NE000269"),
    expected_df %>% filter(codigo_empenho == "250110000012021NE000269")
  ),
  label = "Compra com valor atual zerado")
  
  ## Linhas duplicadas na tabela do histórico de itens geram inconsistências
  expect_true(all_equal(
    output_df %>% filter(codigo_empenho == "194033192082021NE000160"),
    expected_df %>% filter(codigo_empenho == "194033192082021NE000160")
  ),
  label = "Compra com vários eventos no histórico")
  
  expect_true(all_equal(
    output_df %>% filter(codigo_empenho == "160155000012021NE000062"),
    expected_df %>% filter(codigo_empenho == "160155000012021NE000062")
  ),
  label = "Compra com vários itens com histórico")
  
  expect_true(all_equal(
    output_df %>% filter(codigo_empenho == "160040000012021NE000091"),
    expected_df %>% filter(codigo_empenho == "160040000012021NE000091")
  ),
  label = "Compra com apenas inclusão")
  
})
