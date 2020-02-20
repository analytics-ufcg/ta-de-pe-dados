-- NOVIDADE
BEGIN;
CREATE TEMP TABLE temp_novidade AS SELECT * FROM novidade LIMIT 0;

\copy temp_novidade FROM '/data/bd/novidade.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO novidade 
SELECT *
FROM temp_novidade
ON CONFLICT (id_novidade)
DO
  UPDATE
  SET 
    id_tipo = EXCLUDED.id_tipo,
    id_licitacao = EXCLUDED.id_licitacao,
    data = EXCLUDED.data,
    id_original = EXCLUDED.id_original,
    nome_municipio = EXCLUDED.nome_municipio;

DROP TABLE temp_novidade;
COMMIT;
