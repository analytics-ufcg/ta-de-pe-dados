DROP TABLE IF EXISTS orgao;

CREATE TABLE IF NOT EXISTS "orgao" (
    "id_orgao" VARCHAR(32),
    "cd_orgao" INTEGER,
    "nm_orgao" VARCHAR(240),
    "sigla_orgao" VARCHAR(240),
    "esfera" VARCHAR(10),
    "home_page" VARCHAR(50),
    "nome_municipio" VARCHAR(60),
    "cd_municipio_ibge" INTEGER,
    "nome_entidade" VARCHAR(60),
    "sigla_estado" VARCHAR(2),
    "id_estado" INTEGER,
    PRIMARY KEY("id_orgao"),
    FOREIGN KEY("cd_municipio_ibge") REFERENCES municipio("cd_municipio_ibge") ON DELETE CASCADE ON UPDATE CASCADE
);
