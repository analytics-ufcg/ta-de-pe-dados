DROP TABLE IF EXISTS licitante;

CREATE TABLE IF NOT EXISTS "licitante" (    
    "id_licitante" BIGINT,
    "id_licitacao" INTEGER,
    "id_orgao" VARCHAR(20),
    "nr_licitacao" VARCHAR(20),
    "ano_licitacao" INTEGER,
    "cd_tipo_modalidade" VARCHAR(3),
    "tp_documento_licitante" VARCHAR(1),
    "nr_documento_licitante" VARCHAR(14),
    "tp_documento_repres" VARCHAR(1),
    "nr_documento_repres" VARCHAR(14),
    "tp_condicao" VARCHAR(3),
    "tp_resultado_habilitacao" VARCHAR(1),
    "bl_beneficio_micro_epp" VARCHAR(1),
    FOREIGN KEY ("id_licitacao") REFERENCES licitacao ("id_licitacao"),
    CONSTRAINT licitante_key UNIQUE (id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, tp_documento_licitante, 
    nr_documento_licitante),
    PRIMARY KEY("id_licitante")
);
