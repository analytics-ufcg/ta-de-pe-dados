DROP TABLE IF EXISTS item;

CREATE TABLE IF NOT EXISTS "item" (
    "id_item" BIGINT,
    "id_licitacao" INTEGER,
    "id_orgao" INTEGER,
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
    PRIMARY KEY("id_item"),
    CONSTRAINT item_key UNIQUE (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_lote, nr_item),
    FOREIGN KEY("id_licitacao") REFERENCES licitacao("id_licitacao"),
    FOREIGN KEY("id_orgao") REFERENCES orgao("id_orgao")    
);