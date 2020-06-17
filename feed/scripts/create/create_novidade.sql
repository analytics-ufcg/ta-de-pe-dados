DROP TABLE IF EXISTS novidade;

CREATE TABLE IF NOT EXISTS "novidade" ( 
    "id_novidade" VARCHAR(32),
    "id_tipo" INTEGER,
    "id_licitacao" VARCHAR(32),
    "data" DATE,
    "id_original" VARCHAR(32),
    "nome_municipio" VARCHAR(30),
    "texto_novidade" VARCHAR(20),
    "id_contrato" VARCHAR(32),
    PRIMARY KEY("id_novidade"),
    FOREIGN KEY("id_licitacao") REFERENCES licitacao("id_licitacao") ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY("id_tipo") REFERENCES tipo_novidade("id_tipo") ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY("id_contrato") REFERENCES contrato("id_contrato") ON DELETE CASCADE ON UPDATE CASCADE
);
