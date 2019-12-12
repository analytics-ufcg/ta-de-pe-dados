library(tidyverse)
library(data.table)
library(readr)
library(janitor)
library(xlsx)
library(stringr)
library(googlesheets)
library(stringi)
library(stringr)
library(xlsx)


fix_nomes <- function(x){
  
  x <- ifelse(grepl("De", x), gsub( "\\ De", " de", x ), x)
  x <- ifelse(grepl("Da", x), gsub( "\\ Da", " da", x ), x)
  x <- ifelse(grepl("Do", x), gsub( "\\ Do", " do", x ), x)
  x <- ifelse(grepl("Dos", x), gsub( "\\ Dos", " dos", x ), x)
  
}

#Autenticação:
gs_ls() 


ano <- c("2017", "2018", "2019")


#Diretório
setwd("C:/Users/coliv/Documents/brazilian_funds_db/banco_final/merenda/rs")

#

lista <- c("info_contratos.csv","info_estados.csv","info_alteracoes_contrato.csv", 
           "info_item_contrato.csv","info_item_licitacao.csv","info_licitacoes.csv" ,
           "info_municipios.csv","info_rais.csv")

for(i in 1: length(lista)){
  
  print(lista[i])
  
  a <- fread(lista[i], encoding = "UTF-8" )
  l <- gsub(".csv", "", lista)
  n <- l[i]
  
  a <- a %>%
    mutate_all(as.character)
  
  assign(paste0(n), a) 
  
}


# Contratos vigentes

rs <- info_rais %>%
  mutate_all(as.character) %>%
  distinct(nr_documento_contratado, razao_social)

aditivos <- info_alteracoes_contrato %>%
  group_by(id_orgao, ano_contrato, nr_contrato ) %>%
  summarise(qtde_aditivos = n()) %>%
  arrange(desc(qtde_aditivos))


tb1 <- info_contratos %>%
  left_join(info_municipios, by=c("id_estado", "id_orgao")) %>%
  left_join(info_licitacoes, by=c("id_estado", "id_orgao", "nr_licitacao", "ano_licitacao")) %>%
  left_join(rs, by=c("nr_documento_contratado")) %>%
  mutate(contratos = paste(nr_contrato, ano_contrato, sep="/"),
         c1 = substr(nr_documento_contratado, 0, 2),               # Aqui estou dividindo os documentos e colocando 
         c2 = substr(nr_documento_contratado, 3, 5),               # os pontos e traços
         c3 = substr(nr_documento_contratado, 6, 8),
         c4 = substr(nr_documento_contratado, 9, 12),
         c5 = substr(nr_documento_contratado, 13, 14),
         p1 = substr(nr_documento_contratado, 0, 3),
         p2 = substr(nr_documento_contratado, 4, 6),
         p3 = substr(nr_documento_contratado, 7, 9),
         p4 = substr(nr_documento_contratado, 10, 11),
         nr_documento_contratado = ifelse(tp_documento_contratado == "J", paste0(c1, ".", c2, ".", c3, "/", c4, "-", c5),
                                          paste0(p1, ".", p2, ".", p3, "-", p4)),
         tp_documento_contratado = ifelse(tp_documento_contratado == "F", "Física", 
                                          ifelse(tp_documento_contratado == "J", "Jurídica", "Estrangeiro"))) %>%
  left_join(aditivos, by=c("id_orgao", "ano_contrato", "nr_contrato")) %>%
  mutate(qtde_aditivos = ifelse(is.na(qtde_aditivos), "0", qtde_aditivos)) %>%
  select(id_estado, nm_municipio, contratos, descricao_objeto_contrato, dt_inicio_vigencia, dt_final_vigencia, vl_contrato,
                tp_documento_contratado, nr_documento_contratado, razao_social, qtde_aditivos)

names(tb1) <- c("id_estado", "nm_municipio", "Contrato / Ano",
                "Descrição objeto de contrato",	"Início vigência de contrato", "Fim vigência de contrato",
                "Valor contrato", "Natureza",	"CNPJ / CPF",	"Razão social", "Quantidade de aditivos")

setwd("C:/Users/coliv/Documents/brazilian_funds_db/banco_final/merenda/rs/tabelas mvp1")

fwrite(tb1, file="tb1.csv")
write.xlsx(tb1, file="tb1.xlsx", row.names=FALSE, showNA = FALSE)

## Info da empresa 

load("C:/Users/coliv/Documents/brazilian_funds_db/dbs/QSA/RS_qsa.Rdata") #x
load("C:/Users/coliv/licitacoes_merenda_rs/dbs/cruzamentos_contratos/rais_contratos_rs.Rdata")

#Importando:
quest_sheet <- gs_title("Dados de contratos de merenda (respostas)")
dados_empresas <- gs_read(quest_sheet)

dados_empresas <- dados_empresas %>%
  clean_names() %>%
  filter(!grepl("teste", x2_municipio_que_esta_contratando))

munic_contrato <- info_contratos %>%
  filter(tp_documento_contratado == "J") %>%
  mutate(dt_final_vigencia = as.Date(dt_final_vigencia, format = "%Y-%m-%d"),
    vig = ifelse(dt_final_vigencia < "2019-07-01", "vigente", "expirado")) %>%
  left_join(info_municipios, by=c("id_estado","id_orgao")) %>%
  distinct(id_estado, id_orgao, nr_documento_contratado, vig, nm_municipio) 

munic_contrato <- aggregate(munic_contrato$nm_municipio, list(munic_contrato$nr_documento_contratado, munic_contrato$vig), paste, collapse=", ")
names(munic_contrato) <- c("nr_documento_contratado", "vig", "municipios")

munic_contrato <- munic_contrato %>%
  spread(vig, municipios)

cnpjs_rs <- unique(rais_contratos_rs$NR_DOCUMENTO)

qsa_rs <- x %>%
  filter(TIPO == "02",
         CNPJ %in% cnpjs_rs) %>%
  select(CNPJ ,NM_QUALIFICACAO_DO_SOCIO , NOME_DO_SOCIO )

socios <- aggregate(qsa_rs$NOME_DO_SOCIO, list(qsa_rs$CNPJ), paste, collapse=", ") 
names(socios) <- c("CNPJ", "nome_socio")
qualificacao <- aggregate(qsa_rs$NM_QUALIFICACAO_DO_SOCIO, list(qsa_rs$CNPJ), paste, collapse=", ") 
names(qualificacao) <- c("CNPJ", "qualificacao_socio")

qsa_rs <- socios %>%
  left_join(qualificacao) %>%
  mutate(nome_socio = tolower(nome_socio),
         nome_socio = str_to_title(nome_socio))
  


tb2 <- rais_contratos_rs %>%
  mutate_all(as.character) %>%
  mutate(razao_social = gsub("\\.", "", razao_social),
         cep_estab = gsub("\\.", "", cep_estab),
         cep1 = substr(cep_estab, 0, 5),
         cep2 = substr(cep_estab, 6, 8),
         cep_estab = paste0(cep1, "-", cep2)) %>%
  rename(nr_documento_contratado = NR_DOCUMENTO) %>%
  left_join(qsa_rs, by=c("nr_documento_contratado" = "CNPJ") ) %>%
  left_join(munic_contrato, by=c("nr_documento_contratado")) %>%
  rename(munic_contrato_vigente = vigente,
         munic_contrato_expirado = expirado) %>%
  select(cnpj_cei, razao_social, natureza_juridica, cnae_2_0_classe_2, cep_estab, porte_estabelecimento, 
         tamanho_estabelecimento, qtd_vinculos_ativos, nome_socio, qualificacao_socio,
         munic_contrato_vigente, munic_contrato_expirado) 

setwd("C:/Users/coliv/Documents/brazilian_funds_db/banco_final/merenda/rs/tabelas mvp1")

fwrite(tb2, file="tb2.csv")
write.xlsx(tb2, file="tb2.xlsx", row.names=FALSE, showNA = FALSE)


#TB3 - licitações

c <- info_contratos %>%
  select(id_estado, id_orgao, nr_licitacao, ano_licitacao, nr_contrato, ano_contrato, vl_contrato)

tb3 <- info_licitacoes  %>%
  left_join(c, by=c("id_estado", "id_orgao", "nr_licitacao", "ano_licitacao")) %>%
  mutate(tipo_licitacao = ifelse(grepl("Aplica", tipo_licitacao), "Não se aplica", tipo_licitacao)) %>%
  rename(vl_estimado_licitacao_total = vl_estimado_licitacao,
         vl_contrato_com_fornecedor = vl_contrato) %>%
  mutate(licitacao_ano = paste0(nr_licitacao, "/", ano_licitacao ),
         contrato_ano = paste0(nr_contrato, "/", ano_contrato),
         permite_subcontratacao = ifelse(permite_subcontratacao == "S", "Sim", "Não")) %>%
  left_join(info_municipios, by=c("id_estado", "id_orgao")) %>%
  select(id_estado, nm_municipio, licitacao_ano, descricao_objeto,
         tipo_licitacao, permite_subcontratacao, tp_fornecimento, vl_estimado_licitacao_total,total_concorrentes,
         contrato_ano, vl_contrato_com_fornecedor)


setwd("C:/Users/coliv/Documents/brazilian_funds_db/banco_final/merenda/rs/tabelas mvp1")

fwrite(tb3, file="tb3.csv")
write.xlsx(tb3, file="tb3.xlsx", row.names=FALSE, showNA = FALSE)  


# TB4 Itens licitação

tb4 <- info_item_licitacao %>%
  inner_join(info_item_contrato, by=c("id_orgao" = "cd_orgao", "ano_licitacao", "nr_lote", "nr_licitacao",
                                     "nr_item")) %>%
  left_join(info_municipios, by=c("id_orgao")) %>%
  mutate(vl_unitario_estimado = round(as.numeric(vl_unitario_estimado),2),
         vl_total_estimado = round(as.numeric(vl_total_estimado),2),
         qt_itens_licitacao = round(as.numeric(qt_itens_licitacao),0),
         qt_itens_contrato = round(as.numeric(qt_itens_contrato),0),
         vl_item_contrato = round(as.numeric(vl_item_contrato),2),
         vl_total_item_contrato = round(as.numeric(vl_total_item_contrato),2),
         licitacao_ano = paste0(nr_licitacao, "/", ano_licitacao ),
         contrato_ano = paste0(nr_contrato, "/", ano_contrato ),
         ds_item = tolower(ds_item),
         ds_item = str_to_sentence(ds_item),
         qt_itens_licitacao = paste0(qt_itens_licitacao, " ", sg_unidade_medida),
         qt_itens_contrato = paste0(qt_itens_contrato, " ", sg_unidade_medida)) %>%
  select(id_estado.x, nm_municipio, licitacao_ano, nr_item, ds_item, qt_itens_licitacao,  
         vl_unitario_estimado, vl_total_estimado, contrato_ano, qt_itens_contrato , vl_item_contrato,
         vl_total_item_contrato) %>%
  rename(id_estado = id_estado.x)

setwd("C:/Users/coliv/Documents/brazilian_funds_db/banco_final/merenda/rs/tabelas mvp1")

fwrite(tb4, file="tb4.csv")
write.xlsx(tb4, file="tb4.xlsx", row.names=FALSE, showNA = FALSE)  

#Tabela 5 - aditivos

tb5 <- info_contratos %>%
  left_join(info_municipios, by=c("id_estado", "id_orgao")) %>%
  left_join(info_licitacoes, by=c("id_estado", "id_orgao", "nr_licitacao", "ano_licitacao")) %>%
  left_join(rs, by=c("nr_documento_contratado")) %>%
  inner_join(info_alteracoes_contrato, by=c("id_orgao", "ano_contrato", "nr_contrato", "ano_licitacao",
                                           "nr_licitacao")) %>%
  mutate(contratos = paste(nr_contrato, ano_contrato, sep="/"),
         vigencia_novo_contrato = ifelse(!is.na(vigencia_novo_contrato), paste0(vigencia_novo_contrato, " dias"),
                                         vigencia_novo_contrato),
         c1 = substr(nr_documento_contratado, 0, 2),               # Aqui estou dividindo os documentos e colocando 
         c2 = substr(nr_documento_contratado, 3, 5),               # os pontos e traços
         c3 = substr(nr_documento_contratado, 6, 8),
         c4 = substr(nr_documento_contratado, 9, 12),
         c5 = substr(nr_documento_contratado, 13, 14),
         p1 = substr(nr_documento_contratado, 0, 3),
         p2 = substr(nr_documento_contratado, 4, 6),
         p3 = substr(nr_documento_contratado, 7, 9),
         p4 = substr(nr_documento_contratado, 10, 11),
         nr_documento_contratado = ifelse(tp_documento_contratado == "J", paste0(c1, ".", c2, ".", c3, "/", c4, "-", c5),
                                          paste0(p1, ".", p2, ".", p3, "-", p4)),
         tp_documento_contratado = ifelse(tp_documento_contratado == "F", "Física", 
                                          ifelse(tp_documento_contratado == "J", "Jurídica", "Estrangeiro")),
         dt_inicio_vigencia = as.Date(dt_inicio_vigencia, format="%Y-%m-%d"),
         dt_final_vigencia = as.Date(dt_final_vigencia, format="%Y-%m-%d")) %>%
  select(id_estado, nm_municipio, contratos, descricao_objeto_contrato, dt_inicio_vigencia, dt_final_vigencia, vl_contrato,
         tp_documento_contratado, nr_documento_contratado, razao_social, motivo_alteracao_contrato ,
         vigencia_novo_contrato, vl_acrescimo, vl_reducao , ds_justificativa)

  
setwd("C:/Users/coliv/Documents/brazilian_funds_db/banco_final/merenda/rs/tabelas mvp1")

fwrite(tb5, file="tb5.csv")
write.xlsx(tb5, file="tb5.xlsx", row.names=FALSE, showNA = FALSE)  

# Tb6  e Tb7

load("C:/Users/coliv/Documents/brazilian_funds_db/dbs/QSA/RS_qsa.Rdata") #x
load("C:/Users/coliv/licitacoes_merenda_rs/dbs/cruzamentos_contratos/rais_contratos_rs.Rdata")

#Importando:
quest_sheet <- gs_title("Dados de contratos de merenda (respostas)")
dados_quest <- gs_read(quest_sheet)

dados_empresas <- dados_quest %>%
  clean_names() %>%
  mutate(id = gsub(" ", "", carimbo_de_data_hora)) %>%
  filter(!grepl("teste", x2_municipio_que_esta_contratando),
         !is.na(x10_cnpj_da_empresa_contratada_com_tracos_e_pontos))

ids_empresas <- dados_empresas$carimbo_de_data_hora

cpfs_socios <- dados_empresas %>%
  select(x10_cnpj_da_empresa_contratada_com_tracos_e_pontos,
         x11_nome_do_a_representante_da_empresa, 
         x13_cpf_do_a_representante_da_empresa_com_tracos_e_pontos) %>%
  rename(NOME_DO_SOCIO = x11_nome_do_a_representante_da_empresa,
         cpf = x13_cpf_do_a_representante_da_empresa_com_tracos_e_pontos,
         CNPJ = x10_cnpj_da_empresa_contratada_com_tracos_e_pontos) %>%
  mutate(CNPJ = gsub(" ", "", CNPJ),
         cpf = gsub(" ", "", cpf),
         cpf = ifelse(NOME_DO_SOCIO == "CLEVERSON ANDREI NUNES", "028.779.110-63", cpf),
         cpf = ifelse(NOME_DO_SOCIO == "FABIO DE JESUS GONÇALVES DE CARVALHO", "457.252.840-34", cpf),
         NOME_DO_SOCIO = stri_trans_general(NOME_DO_SOCIO, "Latin-ASCII"),
         NOME_DO_SOCIO = toupper(NOME_DO_SOCIO),
         NOME_DO_SOCIO = gsub(",", "", NOME_DO_SOCIO),
         NOME_DO_SOCIO = gsub("PRESIDENTE", "", NOME_DO_SOCIO),
         NOME_DO_SOCIO = gsub("SR. ", "", NOME_DO_SOCIO),
         NOME_DO_SOCIO = trimws(NOME_DO_SOCIO),
         CNPJ = trimws(CNPJ),
         num = nchar(CNPJ),
         CNPJ = ifelse(CNPJ == "12309267/0001-44", "12.309.267/0001-44", CNPJ),
         CNPJ = ifelse(CNPJ == "05047086/0001-21", "05.047.086/0001-21", CNPJ)) %>%
  filter(!is.na(cpf),
         num > 14,
         CNPJ != cpf,
         CNPJ != "IE383.102.408-3") %>%
  distinct(CNPJ,NOME_DO_SOCIO, cpf)

munic_contrato_pj <- info_contratos %>%
  filter(tp_documento_contratado == "J") %>%
  mutate(dt_final_vigencia = as.Date(dt_final_vigencia, format = "%Y-%m-%d"),
         vig = ifelse(dt_final_vigencia < "2019-07-01", "vigente", "expirado")) %>%
  left_join(info_municipios, by=c("id_estado","id_orgao")) %>%
  distinct(id_estado, id_orgao, nr_documento_contratado, vig, nm_municipio) 

munic_contrato_pj <- aggregate(munic_contrato$nm_municipio, list(munic_contrato$nr_documento_contratado, munic_contrato$vig), paste, collapse=", ")
names(munic_contrato_pj) <- c("nr_documento_contratado", "vig", "municipios")

munic_contrato_pj <- munic_contrato_pj %>%
  spread(vig, municipios)

cnpjs_rs <- unique(rais_contratos_rs$NR_DOCUMENTO)

#################### aqui!
tb6 <- x %>%
  filter(TIPO == "02",
         CNPJ %in% cnpjs_rs) %>%
  mutate(c1 = substr(CNPJ, 0, 2),               # Aqui estou dividindo os documentos e colocando 
         c2 = substr(CNPJ, 3, 5),               # os pontos e traços
         c3 = substr(CNPJ, 6, 8),
         c4 = substr(CNPJ, 9, 12),
         c5 = substr(CNPJ, 13, 14),
         CNPJ = paste0(c1, ".", c2, ".", c3, "/", c4, "-", c5)) %>%
  select(CNPJ,NM_QUALIFICACAO_DO_SOCIO , NOME_DO_SOCIO ) %>%
  mutate(NOME_DO_SOCIO = trimws(NOME_DO_SOCIO)) %>%
  left_join(cpfs_socios, by=c( "CNPJ", "NOME_DO_SOCIO"))

setwd("C:/Users/coliv/Documents/brazilian_funds_db/banco_final/merenda/rs/tabelas mvp1")

fwrite(tb6, file="tb6.csv")
write.xlsx(as.data.frame(tb6), file="tb6.xlsx", row.names=FALSE, showNA = FALSE)


#### agricultura familiar:
dados_agricultura_familiar <- dados_quest %>%
  clean_names() %>%
  mutate(id = gsub(" ", "", carimbo_de_data_hora)) %>%
  filter(!grepl("teste", x2_municipio_que_esta_contratando),
         is.na(x10_cnpj_da_empresa_contratada_com_tracos_e_pontos)) %>%
  select(x1_numero_do_termo_de_contrato,
         x2_municipio_que_esta_contratando,
         x3_sigla_do_estado_do_municipio_que_esta_contratando,
         x5_nome_da_pessoa_fisica_contratada,
         x6_municipio_da_pessoa_contratada,
         x8_cep_do_endereco_da_pessoa_contratada,
         x9_logradouro_da_pessoa_contratada,
         x10_cpf_da_pessoa_contratada_com_tracos_e_pontos ) %>%
  rename(contrato_ano = x1_numero_do_termo_de_contrato,
         município_contratante = x2_municipio_que_esta_contratando,
         uf_municipio_contratante = x3_sigla_do_estado_do_municipio_que_esta_contratando,
         nome_pessoa_fisica_contratada = x5_nome_da_pessoa_fisica_contratada,
         municipio_contratada = x6_municipio_da_pessoa_contratada,
         cep_contratada = x8_cep_do_endereco_da_pessoa_contratada,
         logradouro_contratada = x9_logradouro_da_pessoa_contratada,
         cpf_contratada = x10_cpf_da_pessoa_contratada_com_tracos_e_pontos) %>%
  mutate(contrato_ano = gsub("^0", "", contrato_ano),
         contrato_ano = gsub("^0", "", contrato_ano),
         município_contratante = str_to_title(município_contratante),
         município_contratante = fix_nomes(município_contratante),
         municipio_contratada = str_to_title(municipio_contratada),
         municipio_contratada = fix_nomes(municipio_contratada),
         nome_pessoa_fisica_contratada = str_to_title(nome_pessoa_fisica_contratada),
         nome_pessoa_fisica_contratada = fix_nomes(nome_pessoa_fisica_contratada)) #passo duas vezes propositalmente


termos_na <- c("N.a", "N Disponível", "Não consta em contrato", 
               "n disponível", "N.A", "Não informado", "NÃO INFORMADO" )

for(i in 1:length(termos_na)){ 
  dados_agricultura_familiar <- as.data.frame(lapply(dados_agricultura_familiar, function(y) gsub(termos_na[i], NA, y)))
}

tb7 <- dados_agricultura_familiar

setwd("C:/Users/coliv/Documents/brazilian_funds_db/banco_final/merenda/rs/tabelas mvp1")

fwrite(tb7, file="tb7.csv")
write.xlsx(as.data.frame(tb7), file="tb7.xlsx", row.names=FALSE, showNA = FALSE)

### Acho que TB7 eu posso fazer com os dados em transparência ativa


