DROP TABLE IF EXISTS item;

CREATE TABLE IF NOT EXISTS "item" (
    "id_orgao" VARCHAR(20),
    "nr_licitacao" VARCHAR(20),	
    "ano_licitacao" INTEGER,
    "cd_tipo_modalidade" VARCHAR(3),
    "nr_lote" INTEGER,
    "nr_item" INTEGER,
    "ds_item" VARCHAR(2000),
    "qt_itens_licitacao" REAL,
    "sg_unidade_medida" VARCHAR(5),	
    "vl_unitario_estimado" REAL,
    "vl_total_estimado" REAL,
    "item_id" BIGINT,
    "licitacao_id" INTEGER,
    PRIMARY KEY("item_id"),
    FOREIGN KEY("licitacao_id") REFERENCES licitacao("id_licitacao")
    
);