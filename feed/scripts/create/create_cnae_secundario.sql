DROP TABLE IF EXISTS cnae_secundario;

CREATE TABLE IF NOT EXISTS "cnae_secundario" ( 
  "tipo_de_registro" TEXT,
  "indicador" TEXT,
  "tipo_atualizacao" TEXT,
  "cnpj" VARCHAR(14),
  "id_cnae" VARCHAR(7),
  "filler" TEXT,
  PRIMARY KEY("cnpj", "id_cnae"),
  FOREIGN KEY("cnpj") REFERENCES fornecedor("nr_documento") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY("id_cnae") REFERENCES cnae("id_cnae") ON DELETE CASCADE ON UPDATE CASCADE
);
