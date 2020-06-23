library(tidyverse)
library(here)
source(here::here("code/utils/read_utils.R"))

## Importando dados

licitacoes <- read_licitacoes_processadas()

contratos <- read_contratos_processados()

empenhos <- read_empenhos_processados()


## Quais licitações sem contratos tem pagamentos/liquidações associados?

pag_liq_licitacoes_sem_contratos_com_pagamentos <- licitacoes %>%
  filter(!(id_licitacao %in%
             (
               contratos %>%
                 distinct(id_licitacao) %>%
                 pull(id_licitacao)
             ))) %>% 
  select(id_licitacao, id_orgao) %>% 
  left_join(empenhos, by = c("id_licitacao", "id_orgao")) %>% 
  filter(!is.na(id_empenho),
         !is.na(vl_liquidacao) | !is.na(vl_pagamento))


licitacoes_info <- pag_liq_licitacoes_sem_contratos_com_pagamentos %>% 
  select(id_licitacao) %>% 
  left_join(licitacoes,
            by = c("id_licitacao")) %>%
  distinct()

## Escrevendo dados
write_csv(pag_liq_licitacoes_sem_contratos_com_pagamentos, 
          here::here("reports/pagamentos-eda/data/pag_liq_sem_contratos.csv"))

write_csv(licitacoes_info, 
          here::here("reports/pagamentos-eda/data/licitacoes_sem_contratos_com_pag_liq.csv"))
