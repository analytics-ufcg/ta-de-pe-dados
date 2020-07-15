DROP TABLE IF EXISTS documento_licitacao;

CREATE TABLE IF NOT EXISTS "documento_licitacao" (
    "id_documento_licitacao" VARCHAR(32),
    "id_licitacao" VARCHAR(32),
    "id_orgao" INTEGER,
    "nr_licitacao" VARCHAR(20),
    "ano_licitacao" INTEGER,
    "cd_tipo_modalidade" VARCHAR(3),
    "cd_tipo_documento" VARCHAR(3),
    "nome_arquivo_documento" VARCHAR(240),
    "cd_tipo_fase" VARCHAR(3),
    "id_evento_licitacao" VARCHAR(10),
    "tp_documento" VARCHAR(3),
    "nr_documento" VARCHAR(20),
    "arquivo_timestamp" VARCHAR(14),
    "arquivo_url_download" VARCHAR(80),
    "descricao_tipo_documento" VARCHAR(60),
    PRIMARY KEY("id_documento_licitacao"),
    CONSTRAINT documento_licitacao_key UNIQUE (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, cd_tipo_documento, nome_arquivo_documento, cd_tipo_fase, id_evento_licitacao, tp_documento, nr_documento),
    FOREIGN KEY("id_licitacao") REFERENCES licitacao("id_licitacao") ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY("id_orgao") REFERENCES orgao("id_orgao") ON DELETE CASCADE ON UPDATE CASCADE
);
