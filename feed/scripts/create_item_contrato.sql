DROP TABLE IF EXISTS item_contrato;

CREATE TABLE IF NOT EXISTS "item_contrato" (
    "id_orgao" VARCHAR(20),
    "nr_lote" INTEGER,
    "nr_licitacao" INTEGER,
    "ano_licitacao" INTEGER,
    "cd_tipo_modalidade" VARCHAR(3),
    "nr_contrato" INTEGER,
    "ano_contrato" INTEGER,
    "tp_instrumento_contrato" VARCHAR(),
    "nr_item" INTEGER,
    "qt_itens_contrato" INTEGER,
    "vl_item_contrato" REAL,
    "vl_total_item_contrato" INTEGER,
    "nm_orgao" VARCHAR(240),
    "nr_processo" VARCHAR(),
    "ano_processo" INTEGER,
    "tp_documento_contratado" VARCHAR(2),
    "nr_documento_contratado" VARCHAR(),
    "dt_inicio_vigencia" DATE,
    "dt_final_vigencia" DATE,
    "vl_contrato" REAL,
    "contrato_possui_garantia" VARCHAR(),
    "vigencia_original_do_contrato" INTEGER,
    "descricao_objeto_contrato" VARCHAR(),
    "justificativa_contratacao" VARCHAR(),
    "obs_contrato" VARCHAR(),
    "id_item_contrato" BIGINT,
    "id_contrato" BIGINT,
    PRIMARY KEY ("id_item_contrato"),
    FOREIGN KEY ("id_licitacao") REFERENCES licitacao("id_licitacao")

    
);