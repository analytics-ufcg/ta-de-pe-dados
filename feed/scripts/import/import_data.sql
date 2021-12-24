SET datestyle = ymd;
CREATE EXTENSION pg_trgm;

\copy municipio FROM '/data/bd/info_municipios_monitorados.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy orgao FROM '/data/bd/info_orgaos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy licitacao FROM '/data/bd/info_licitacao.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy documento_licitacao FROM '/data/bd/info_documento_licitacao.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy item FROM '/data/bd/info_item_licitacao.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy fornecedor FROM '/data/bd/info_fornecedores_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy cnae FROM '/data/bd/info_cnaes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy natureza_juridica FROM '/data/bd/natureza_juridica.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy dados_cadastrais FROM '/data/bd/dados_cadastrais.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy socios FROM '/data/bd/socios.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy cnae_secundario FROM '/data/bd/cnaes_secundarios.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy contrato FROM '/data/bd/info_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy item_contrato FROM '/data/bd/info_item_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy licitante FROM '/data/bd/info_licitante.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

ALTER TABLE licitacao ADD COLUMN language VARCHAR(10);
UPDATE licitacao SET language = 'portuguese';

ALTER TABLE orgao ADD COLUMN language VARCHAR(10);
UPDATE orgao SET language = 'portuguese';


CREATE MATERIALIZED VIEW item_search AS 
SELECT o.nome_municipio, i.ano_licitacao, i.id_item_contrato, i.id_contrato, i.nr_contrato, 
    i.dt_inicio_vigencia, i.id_licitacao, c.tipo_instrumento_contrato, i.nr_licitacao,
    i.qt_itens_contrato, i.vl_item_contrato, i.vl_total_item_contrato, ds_item, i.sg_unidade_medida, 
    i.servico, i.id_estado, i.sigla_estado, i.tem_inconsistencia,
    setweight(to_tsvector(i.language :: regconfig,i.ds_1),'A') || 
    setweight(to_tsvector(i.language :: regconfig,i.ds_2),'C') || 
    setweight(to_tsvector(i.language :: regconfig,i.ds_3),'D') || 
    setweight(to_tsvector(i.language :: regconfig,i.ds_item),'D') AS document 
FROM item_contrato AS i
LEFT JOIN orgao AS o
ON i.id_orgao = o.id_orgao
LEFT JOIN contrato as c
ON i.id_contrato = c.id_contrato;

CREATE INDEX idx_item_search ON item_search USING gin(document);

CREATE MATERIALIZED VIEW unique_lexeme AS
SELECT word FROM ts_stat(
'SELECT to_tsvector(item_contrato.language :: regconfig, item_contrato.ds_item) ||
	to_tsvector(contrato.language :: regconfig, contrato.descricao_objeto_contrato) ||
	to_tsvector(licitacao.language :: regconfig, licitacao.descricao_objeto) ||
	to_tsvector(orgao.language :: regconfig, orgao.nome_municipio)
FROM item_contrato
JOIN contrato ON contrato.id_contrato = item_contrato.id_contrato 
JOIN licitacao ON licitacao.id_licitacao = contrato.id_licitacao
JOIN orgao ON orgao.id_orgao = licitacao.id_orgao');

CREATE INDEX words_idx ON unique_lexeme USING gin(word gin_trgm_ops);
