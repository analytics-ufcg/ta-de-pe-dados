DROP TABLE IF EXISTS natureza_juridica;

CREATE TABLE IF NOT EXISTS "natureza_juridica" ( 
  "codigo_natureza_juridica" VARCHAR(4),
  "nome_subclasse_natureza_juridica" VARCHAR(100),
  "codigo_classe_natureza_juridica" VARCHAR(1),
  "nome_classe_natureza_juridica" VARCHAR(100),
  PRIMARY KEY("codigo_natureza_juridica")
);
