\copy licitacao FROM '/data/licitacoes/2019/licitacao.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;

ALTER TABLE empenho DROP CONSTRAINT empenho_pkey;
\copy empenho FROM '/data/empenhos/2019/2019.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;


