SET datestyle = ymd;
\copy licitacao FROM '/data/bd/info_licitacao.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy item FROM '/data/bd/info_item_licitacao.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy contrato FROM '/data/bd/info_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy alteracoes_contrato FROM '/data/bd/info_alteracao_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

-- ALTER TABLE empenho DROP CONSTRAINT empenho_pkey;
-- ALTER TABLE empenho DROP CONSTRAINT empenho_cd_orgao_fkey;
-- \copy empenho FROM '/data/empenhos/2019/2019.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;

