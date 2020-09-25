DROP TABLE IF EXISTS dados_cadastrais;

CREATE TABLE IF NOT EXISTS "dados_cadastrais" ( 
  "tipo_de_registro" TEXT,
  "indicador" TEXT,
  "tipo_atualizacao" TEXT,
  "cnpj" VARCHAR(14),
  "identificador_matriz_filial" TEXT,
  "razao_social" TEXT,
  "nome_fantasia" TEXT,
  "situacao_cadastral" TEXT,
  "data_situacao_cadastral" TEXT,
  "motivo_situacao_cadastral" TEXT,
  "nm_cidade_exterior" TEXT,
  "cod_pais" TEXT,
  "nm_pais" TEXT,
  "codigo_natureza_juridica" TEXT,
  "data_inicio_atividade" TEXT,
  "cnae_fiscal" TEXT,
  "descricao_tipo_logradouro" TEXT,
  "logradouro" TEXT,
  "numero" TEXT,
  "complemento" TEXT,
  "bairro" TEXT,
  "cep" TEXT,
  "uf" TEXT,
  "codigo_municipio" TEXT,
  "municipio" TEXT,
  "ddd_telefone_1" TEXT,
  "ddd_telefone_2" TEXT,
  "ddd_fax" TEXT,
  "correio_eletronico" TEXT,
  "qualificacao_responsavel" TEXT,
  "capital_social_empresa" REAL,
  "porte_empresa" TEXT,
  "opcao_pelo_simples" TEXT,
  "data_opcao_pelo_simples" TEXT,
  "data_exclusao_simples" TEXT,
  "opcao_pelo_mei" TEXT,
  "situacao_especial" TEXT,
  "data_situacao_especial" TEXT,
  "filler" TEXT,
  "fim_registro" TEXT,
  PRIMARY KEY("cnpj"),
  FOREIGN KEY("cnpj") REFERENCES fornecedor("nr_documento") ON DELETE CASCADE ON UPDATE CASCADE
);
