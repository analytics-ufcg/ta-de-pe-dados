DROP TABLE IF EXISTS tipo_novidade;

CREATE TABLE IF NOT EXISTS "tipo_novidade" ( 
    "id_tipo" INTEGER,
    "texto_evento" VARCHAR(240),
    PRIMARY KEY("id_tipo")
    
);
