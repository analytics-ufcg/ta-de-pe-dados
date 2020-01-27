DROP TABLE IF EXISTS licitacao;

CREATE TABLE IF NOT EXISTS "licitacao" ( 
    "id_licitacao" INTEGER,
    "id_estado" INTEGER,   
    "id_orgao" INTEGER,
    "nm_orgao" VARCHAR(240),
    "nr_licitacao" VARCHAR(20),
    "ano_licitacao" INTEGER,
    "cd_tipo_modalidade" VARCHAR(3),
    "permite_subcontratacao" VARCHAR(1),
    "tp_fornecimento" VARCHAR(10),
    "descricao_objeto" TEXT,
    "vl_estimado_licitacao" REAL,
    "data_abertura" DATE,
    "data_homologacao" DATE,
    "data_adjudicacao" DATE,
    "vl_homologado" REAL,
    "tp_licitacao" VARCHAR(3),
    "tipo_licitacao" VARCHAR(100),
    PRIMARY KEY("id_licitacao"),
    FOREIGN KEY("id_orgao") REFERENCES orgao("id_orgao")
);
