
SET datestyle = ymd;
\copy empenho_raw FROM '/data/dados_federais/despesa_empenho.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;
\copy empenho_raw FROM '/data/dados_federais/despesa_item_empenho.csv' WITH NULL AS '' DELIMITER ',' CSV HEADER;

