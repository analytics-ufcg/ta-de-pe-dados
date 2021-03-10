library(readr)
library(tabulizer)
library(dplyr)
library(janitor)
library(xlsx)

ufs_br <- c("AC","AL","AM","AP", "BA","CE","DF","ES","GO","MA","MG","MS","MT","PA","PB","PE","PI","PR","RJ","RN",
            "RO","RR","RS","SC","SE","SP","TO")

## Tabelas de qualificações dos sócios

url <- 'http://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/Qualificacao_socio.pdf'

# Extract the table
out1 <- extract_tables(url,output = "data.frame", encoding = "UTF-8")

nm_qualificacao_socio <- as.data.frame(out1[[1]])
names(nm_qualificacao_socio) <- c("QUALIFICACAO_DO_SOCIO", "NM_QUALIFICACAO_DO_SOCIO")
nm_qualificacao_socio <- nm_qualificacao_socio %>% mutate_all(as.character) 


# Fiz uma primeira extração do QSA de teste

url2 <- c("http://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/consultas/download/SociosAC.txt")
SociosAC <- read_csv(url2, col_names = FALSE)

# 01  01566132000148   TETO INCORPORACOES E CONSTRUCOES LTDA                                                                                                                                         
# 02  01566132000148   2   00000000000000   49   JOSE MAURICIO UMBELINO LOBO         

sAC <-  SociosAC %>%
  rename(dado_original = X1) %>%
  mutate(TIPO = substr(dado_original, 1, 2),
         NM_TIPO = ifelse(TIPO == "01", "informação da empresa", "informação do sócio"),
         CNPJ = substr(dado_original, 3, 16),
         NOME_EMPRESARIAL = ifelse(TIPO == "01", substr(dado_original, 17, 150), NA),
         INDICADOR_CPF_CNPJ = ifelse(TIPO == "02", substr(dado_original, 17, 17), NA),
         NM_INDICADOR_CPF_CNPJ = ifelse(INDICADOR_CPF_CNPJ == "1", "pessoa jurídica", 
                                        ifelse(INDICADOR_CPF_CNPJ == "2", "pessoa física", "nome exterior")),
         CPF_CNPJ_SOCIO = ifelse(TIPO == "02", substr(dado_original, 18, 31), NA),
         QUALIFICACAO_DO_SOCIO = ifelse(TIPO == "02", substr(dado_original, 32, 33), NA),
         NOME_DO_SOCIO = ifelse(TIPO == "02", substr(dado_original, 34, 190), NA),
         ATUALIZACAO = "2018-08-03",
         UF = "AC") %>%
  left_join(nm_qualificacao_socio) %>%
  select(1:9, 13, 10, 11, 12)

QSA <- list()
QSA[[1]] <- sAC

######## Aqui do segundo estado em diante:

i = 2

url3 <- c("http://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/consultas/download/SociosESTADO.txt")
setwd("C:/Users/coliv/Documents/brazilian_funds_db/dbs/QSA") 

for(i in 27:length(ufs_br)){
  
  print(ufs_br[i])
  url <- gsub("ESTADO", ufs_br[i], url3)
  x <- read_delim(url, delim = "|", col_names = FALSE)
  
  x <- x %>%
    rename(dado_original = X1) %>%
    mutate(TIPO = substr(dado_original, 1, 2),
         NM_TIPO = ifelse(TIPO == "01", "informação da empresa", "informação do sócio"),
         CNPJ = substr(dado_original, 3, 16),
         NOME_EMPRESARIAL = ifelse(TIPO == "01", substr(dado_original, 17, 150), NA),
         INDICADOR_CPF_CNPJ = ifelse(TIPO == "02", substr(dado_original, 17, 17), NA),
         NM_INDICADOR_CPF_CNPJ = ifelse(INDICADOR_CPF_CNPJ == "1", "pessoa jurídica", 
                                        ifelse(INDICADOR_CPF_CNPJ == "2", "pessoa física", "nome exterior")),
         CPF_CNPJ_SOCIO = ifelse(TIPO == "02", substr(dado_original, 18, 31), NA),
         QUALIFICACAO_DO_SOCIO = ifelse(TIPO == "02", substr(dado_original, 32, 33), NA),
         NOME_DO_SOCIO = ifelse(TIPO == "02", substr(dado_original, 34, 190), NA),
         ATUALIZACAO = "2018-08-03",
         UF = ufs_br[i]) %>%
    left_join(nm_qualificacao_socio) %>%
    select(1:9, 13, 10, 11, 12) 
  
  arq <- paste0(ufs_br[i], "_qsa.rData")
  
  save(x, file=arq)  
}

