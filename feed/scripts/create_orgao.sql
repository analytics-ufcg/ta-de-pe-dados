DROP TABLE IF EXISTS orgao;

CREATE TABLE IF NOT EXISTS "orgao" ( 
    "id_orgao" VARCHAR(20),
    "id_estado" INTEGER,  
    "nm_orgao" VARCHAR(240),
    PRIMARY KEY("id_orgao")
);