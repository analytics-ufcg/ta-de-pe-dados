SET datestyle = ymd;

CREATE TEMP TABLE empenhos_raw_federais_tmp
AS
SELECT *
FROM empenhos_raw_federais
WITH NO DATA;

-- ADD PRIMARY KEY AUTO_INCREMENT empenhos_raw_federais_tmp ???

\copy empenhos_raw_federais_tmp FROM PROGRAM 'gzip -dc /data/dados_federais/despesa_empenho.csv.gz' WITH NULL AS '' DELIMITER ',' CSV HEADER;

INSERT INTO empenhos_raw_federais
SELECT DISTINCT ON (id) *
FROM empenhos_raw_federais_tmp;

DROP TABLE empenhos_raw_federais_tmp;

\copy itens_empenhos_raw_federais FROM PROGRAM 'gzip -dc /data/dados_federais/despesa_item_empenho.csv.gz' WITH NULL AS '' DELIMITER ',' CSV HEADER;
\copy itens_historico_raw_federais FROM PROGRAM 'gzip -dc /data/dados_federais/despesa_item_historico.csv.gz' WITH NULL AS '' DELIMITER ',' CSV HEADER;