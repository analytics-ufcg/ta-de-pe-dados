\copy tipo_alerta FROM '/data/bd/tipo_alerta.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy alerta FROM '/data/bd/alerta.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy item_atipico FROM '/data/bd/itens_atipicos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;