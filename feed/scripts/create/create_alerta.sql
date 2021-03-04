DROP TABLE IF EXISTS alerta;

CREATE TABLE IF NOT EXISTS "alerta" ( 
    "id_alerta" VARCHAR(32),
    "nr_documento" VARCHAR(14),
    "id_contrato" VARCHAR(32),
    "id_tipo" INTEGER,
    "info" VARCHAR(240),
    PRIMARY KEY("id_alerta"),
    FOREIGN KEY("nr_documento") REFERENCES fornecedor("nr_documento") ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY("id_tipo") REFERENCES tipo_alerta("id_tipo") ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY("id_contrato") REFERENCES contrato("id_contrato") ON DELETE CASCADE ON UPDATE CASCADE
);
