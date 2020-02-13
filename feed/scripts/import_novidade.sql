\copy tipo_novidade FROM '/data/bd/tipo_novidade.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy novidade FROM '/data/bd/novidade.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;