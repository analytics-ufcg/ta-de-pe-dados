DROP TABLE IF EXISTS empenho;

CREATE TABLE IF NOT EXISTS "empenho" (    
    "ano_recebimento" INTEGER,
    "mes_recebimento" INTEGER,
    "cd_orgao" VARCHAR(20),
    "nome_orgao" VARCHAR(240),
    "cd_recebimento" INTEGER,
    "cd_orgao_orcamentario" INTEGER,
    "nome_orgao_orcamentario" VARCHAR(240),
    "cd_unidade_orcamentaria" INTEGER,
    "nome_unidade_orcamentaria" VARCHAR(240),
    "tp_unidade" VARCHAR(40),
    "tipo_operacao" VARCHAR(40),
    "ano_empenho" INTEGER,
    "ano_operacao" INTEGER,
    "dt_empenho" DATE,
    "dt_operacao" DATE,
    "nr_empenho" VARCHAR(40),
    "cd_funcao" INTEGER,
    "ds_funcao" VARCHAR(240),
    "cd_subfuncao" INTEGER,
    "ds_subfuncao" VARCHAR(240),
    "cd_programa" INTEGER,
    "ds_programa" VARCHAR(240),
    "cd_projeto" VARCHAR(240),
    "nm_projeto" VARCHAR(240),
    "cd_elemento" VARCHAR(40),
    "cd_rubrica" VARCHAR(240),
    "ds_rubrica" VARCHAR(240),
    "cd_recurso" VARCHAR(240),
    "nm_recurso" VARCHAR(240),
    "cd_credor" VARCHAR(240),
    "nm_credor" VARCHAR(240),
    "cnpj_cpf" VARCHAR(14),
    "cgc_te" VARCHAR(240),
    "historico" TEXT,
    "vl_empenho" REAL,
    "nr_liquidacao" VARCHAR(40),
    "vl_liquidacao" REAL,
    "nr_pagamento" VARCHAR(40),
    "vl_pagamento" REAL,
    "ano_licitacao" INTEGER,
    "nr_licitacao" VARCHAR(20),
    "mod_licitacao" VARCHAR(240),
    "ano_contrato" INTEGER,
    "nr_contrato" VARCHAR(40),
    "tp_instrumento_contratual" VARCHAR(240),
    FOREIGN KEY (cd_orgao, nr_licitacao, ano_licitacao, mod_licitacao) REFERENCES licitacao ("CD_ORGAO", "NR_LICITACAO", "ANO_LICITACAO", "CD_TIPO_MODALIDADE"),
    PRIMARY KEY("cd_orgao", "cd_orgao_orcamentario", "cd_unidade_orcamentaria", "tp_unidade", "tipo_operacao", "ano_empenho", "ano_operacao", "nr_empenho", "nr_licitacao", "ano_licitacao", "mod_licitacao", "dt_empenho", "dt_operacao", "cd_credor")
);