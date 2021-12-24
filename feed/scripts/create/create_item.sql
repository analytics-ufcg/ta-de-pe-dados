DROP TABLE IF EXISTS item;

CREATE TABLE IF NOT EXISTS "item" (
    "id_item" VARCHAR(32),
    "id_licitacao" VARCHAR(32),
    "id_orgao" VARCHAR(32),
    "cd_orgao" INTEGER,
    "nr_licitacao" VARCHAR(20),	
    "ano_licitacao" INTEGER,
    "cd_tipo_modalidade" VARCHAR(3),
    "nr_lote" INTEGER,
    "nr_item" INTEGER,
    "ds_item" VARCHAR(3000),
    "qt_itens_licitacao" REAL,
    "sg_unidade_medida" VARCHAR(30),	
    "vl_unitario_estimado" NUMERIC(15, 2),
    "vl_total_estimado" NUMERIC(15, 2),
    "sigla_estado" VARCHAR(2),
    "id_estado" INTEGER,   
    PRIMARY KEY("id_item"),
    CONSTRAINT item_key UNIQUE (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_lote, nr_item),
    FOREIGN KEY("id_licitacao") REFERENCES licitacao("id_licitacao") ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY("id_orgao") REFERENCES orgao("id_orgao") ON DELETE CASCADE ON UPDATE CASCADE  
);
