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
SELECT ano_licitacao, id_item_contrato, id_contrato, dt_inicio_vigencia, id_licitacao, vl_item_contrato, vl_total_item_contrato, ds_item,
    setweight(to_tsvector(item_contrato.language :: regconfig,item_contrato.ds_1),'A') || 
    setweight(to_tsvector(item_contrato.language :: regconfig,item_contrato.ds_2),'C') || 
    setweight(to_tsvector(item_contrato.language :: regconfig,item_contrato.ds_3),'D') || 
    setweight(to_tsvector(item_contrato.language :: regconfig,item_contrato.ds_item),'D') AS document 
FROM item_contrato;

CREATE INDEX idx_item_search ON item_search USING gin(document);