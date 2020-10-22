\copy tipo_alerta FROM '/data/bd/tipo_alerta.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy alerta FROM '/data/bd/alerta.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;