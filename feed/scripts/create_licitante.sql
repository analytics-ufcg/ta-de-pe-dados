DROP TABLE IF EXISTS licitante;

CREATE TABLE IF NOT EXISTS "licitante" (    
    "cd_orgao" VARCHAR(20),
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
    "licitante_id" INTEGER,
    "licitacao_id" INTEGER,
    PRIMARY KEY("licitante_id")
    FOREIGN KEY (licitacao_id) REFERENCES licitacao ("licitacao_id"),
);
