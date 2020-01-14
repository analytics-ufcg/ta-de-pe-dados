\copy licitacao FROM '/data/licitacoes/2019/licitacao.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;

SET datestyle = ymd;
\copy item FROM '/data/licitacoes/2019/item.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

