DROP TABLE IF EXISTS contrato;

CREATE TABLE IF NOT EXISTS "contrato" ( 
    "id_contrato" VARCHAR(20),
    "id_licitacao" INTEGER,
    "nr_contrato" VARCHAR(20),
    "ano_contrato" INTEGER,
    "id_orgao" VARCHAR(20),
    "nm_orgao" VARCHAR(240),
    "nr_licitacao" VARCHAR(20),
    "ano_licitacao" INTEGER,
    "cd_tipo_modalidade" VARCHAR(3),
    "tp_instrumento_contrato" VARCHAR(1),
    "nr_processo" VARCHAR(20),
    "ano_processo" INTEGER,
    "tp_documento_contratado" VARCHAR(1),
    "nr_documento_contratado" VARCHAR(14),
    "dt_inicio_vigencia" DATE,
    "dt_final_vigencia" DATE,
    "vl_contrato" REAL,
    "contrato_possui_garantia" VARCHAR(1),
    "vigencia_original_do_contrato" INTEGER,
    "descricao_objeto_contrato" VARCHAR(500),
    "justificativa_contratacao" VARCHAR(300),
    "obs_contrato" VARCHAR(500),
    "tipo_instrumento_contrato" VARCHAR(50),
    PRIMARY KEY("id_contrato"),
    FOREIGN KEY("id_licitacao") REFERENCES licitacao("id_licitacao")
);