\copy licitacao FROM '/data/licitacoes/2019/licitacao.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;

\copy item FROM '/data/licitacoes/2019/item.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;

