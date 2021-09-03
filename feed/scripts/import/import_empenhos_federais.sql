
SET datestyle = ymd;
\copy empenhos_raw_federais FROM '/data/dados_federais/despesa_empenho.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;
\copy itens_empenhos_raw_federais FROM '/data/dados_federais/despesa_item_empenho.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;

