SET datestyle = ymd;
\copy orgao FROM '/data/bd/info_orgaos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy licitacao FROM '/data/bd/info_licitacao.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy item FROM '/data/bd/info_item_licitacao.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy fornecedor FROM '/data/bd/info_fornecedores_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy contrato FROM '/data/bd/info_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy alteracoes_contrato FROM '/data/bd/info_alteracao_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy item_contrato FROM '/data/bd/info_item_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy licitante FROM '/data/bd/info_licitante.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;


CREATE MATERIALIZED VIEW item_search AS 
SELECT o.nome_municipio, i.ano_licitacao, i.id_item_contrato, i.id_contrato, i.nr_contrato, i.dt_inicio_vigencia, i.id_licitacao, 
    i.vl_item_contrato, i.vl_total_item_contrato, ds_item, i.sg_unidade_medida,
    setweight(to_tsvector(i.language :: regconfig,i.ds_1),'A') || 
    setweight(to_tsvector(i.language :: regconfig,i.ds_2),'C') || 
    setweight(to_tsvector(i.language :: regconfig,i.ds_3),'D') || 
    setweight(to_tsvector(i.language :: regconfig,i.ds_item),'D') AS document 
FROM item_contrato AS i
LEFT JOIN orgao AS o
ON i.id_orgao = o.id_orgao;

CREATE INDEX idx_item_search ON item_search USING gin(document);
