\copy empenho FROM PROGRAM 'gzip -dc /data/despesa_empenho.csv.gz' WITH NULL AS '' DELIMITER ',' CSV HEADER;
\copy item_empenho FROM PROGRAM 'gzip -dc /data/despesa_item_empenho.csv.gz' WITH NULL AS '' DELIMITER ',' CSV HEADER;
