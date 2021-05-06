DROP TABLE IF EXISTS item_atipico;

CREATE TABLE IF NOT EXISTS "item_atipico" ( 
    "id_item_atipico" VARCHAR(32),
    "id_alerta" VARCHAR(32),
    "id_item_contrato" VARCHAR(32),
    "id_contrato" VARCHAR(32),
    "ds_item" TEXT,
    "total_vendas_item" INTEGER,
    "n_vendas_semelhantes" INTEGER,
    "perc_vendas_semelhantes" REAL,
    PRIMARY KEY("id_item_atipico"),
    FOREIGN KEY("id_alerta") REFERENCES alerta("id_alerta") ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY("id_item_contrato") REFERENCES item_contrato("id_item_contrato") ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY("id_contrato") REFERENCES contrato("id_contrato") ON DELETE CASCADE ON UPDATE CASCADE
);
