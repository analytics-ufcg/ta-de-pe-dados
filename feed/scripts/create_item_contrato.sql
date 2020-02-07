DROP TABLE IF EXISTS item_contrato;

CREATE TABLE IF NOT EXISTS "item_contrato" (
    "id_item_contrato" VARCHAR(20),
    "id_contrato" VARCHAR(20),
    "id_orgao" INTEGER,
    "id_licitacao" INTEGER,
    "nr_lote" INTEGER,
    "nr_licitacao" INTEGER,
    "ano_licitacao" INTEGER,
    "cd_tipo_modalidade" VARCHAR(3),
    "nr_contrato" INTEGER,
    "ano_contrato" INTEGER,
    "tp_instrumento_contrato" VARCHAR(1),
    "nr_item" INTEGER,
    "qt_itens_contrato" INTEGER,
    "vl_item_contrato" REAL,
    "vl_total_item_contrato" REAL,
    PRIMARY KEY ("id_item_contrato"),
    FOREIGN KEY ("id_contrato") REFERENCES contrato("id_contrato"),
    FOREIGN KEY ("id_orgao") REFERENCES orgao("id_orgao"),
    FOREIGN KEY ("id_licitacao") REFERENCES licitacao("id_licitacao")

);