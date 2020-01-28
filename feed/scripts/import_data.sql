SET datestyle = ymd;
\copy orgao FROM '/data/bd/info_orgaos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy licitacao FROM '/data/bd/info_licitacao.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy item FROM '/data/bd/info_item_licitacao.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
ALTER TABLE empenho_raw DROP CONSTRAINT empenho_raw_pkey;
\copy empenho_raw FROM '/data/empenhos/2019/2019.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;
