DROP TABLE IF EXISTS novidade;

CREATE TABLE IF NOT EXISTS "novidade" ( 
    "id_novidade" BIGINT, 
    "id_tipo" INTEGER,
    "id_licitacao" INTEGER,
    "data" DATE,
    "id_original" BIGINT,
    "nome_municipio" VARCHAR(30),
    "texto_novidade" VARCHAR(60),
    PRIMARY KEY("id_novidade"),
    FOREIGN KEY("id_licitacao") REFERENCES licitacao("id_licitacao"),
    FOREIGN KEY("id_tipo") REFERENCES tipo_novidade("id_tipo")
);
