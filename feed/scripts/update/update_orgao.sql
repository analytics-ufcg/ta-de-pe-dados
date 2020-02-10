-- ORGAO
BEGIN;
CREATE TEMP TABLE temp_orgao AS SELECT * FROM orgao LIMIT 0;

\copy temp_orgao FROM '/data/bd/info_orgaos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO orgao 
SELECT *
FROM temp_orgao
ON CONFLICT (id_orgao)
DO
  UPDATE
  SET
    id_estado = EXCLUDED.id_estado,    
    nm_orgao = EXCLUDED.nm_orgao;

DROP TABLE temp_orgao;
COMMIT;
