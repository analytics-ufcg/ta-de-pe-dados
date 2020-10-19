DROP TABLE IF EXISTS cnae;

CREATE TABLE IF NOT EXISTS "cnae" ( 
  "cod_secao" VARCHAR(2),
  "nm_secao" VARCHAR(80),
  "cod_divisao" VARCHAR(2),
  "nm_divisao" TEXT,
  "cod_grupo" VARCHAR(4),
  "nm_grupo" TEXT,
  "cod_classe" VARCHAR(10),
  "nm_classe" TEXT,
  "id_cnae" VARCHAR(7),
  "nm_cnae" TEXT,
  PRIMARY KEY("id_cnae")
);
