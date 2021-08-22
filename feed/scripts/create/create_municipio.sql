DROP TABLE IF EXISTS municipio;

CREATE TABLE IF NOT EXISTS "municipio" (
    "cd_municipio_ibge" INTEGER,
    "nome_municipio" VARCHAR(60),
    "id_estado" INTEGER,
    "sigla_estado" VARCHAR(2),
    "slug_municipio" VARCHAR(100),
    PRIMARY KEY("cd_municipio_ibge")
);
