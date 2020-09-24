DROP TABLE IF EXISTS socios;

CREATE TABLE "socios" (
  "tipo_de_registro" TEXT,
  "indicador" TEXT,
  "tipo_atualizacao" TEXT,
  "cnpj" VARCHAR(14),
  "identificador_socio" TEXT,
  "nome_socio" TEXT,
  "cnpj_cpf_socio" TEXT,
  "cod_qualificacao_socio" TEXT,
  "percentual_capital_socio" TEXT,
  "data_entrada_sociedade" TEXT,
  "cod_pais" TEXT,
  "nome_pais_socio" TEXT,
  "cpf_representante_legal" TEXT,
  "nome_representante" TEXT,
  "cod_qualificacao_representante_legal" TEXT,
  "fillter" TEXT,
  "fim_registro" TEXT,
  FOREIGN KEY("cnpj") REFERENCES dados_cadastrais("cnpj") ON DELETE CASCADE ON UPDATE CASCADE
);