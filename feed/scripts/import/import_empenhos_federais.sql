SET datestyle = ymd;
\copy empenhos_raw_federais FROM PROGRAM 'gzip -dc /data/dados_federais/despesa_empenho.csv.gz' WITH NULL AS '' DELIMITER ',' CSV HEADER;
\copy itens_empenhos_raw_federais FROM PROGRAM 'gzip -dc /data/dados_federais/despesa_item_empenho.csv.gz' WITH NULL AS '' DELIMITER ',' CSV HEADER;