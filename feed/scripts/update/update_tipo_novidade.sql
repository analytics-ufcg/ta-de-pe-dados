-- TIPO NOVIDADE
BEGIN;
CREATE TEMP TABLE temp_tipo_novidade AS SELECT * FROM tipo_novidade LIMIT 0;

\copy temp_tipo_novidade FROM '/data/bd/tipo_novidade.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO tipo_novidade 
SELECT *
FROM temp_tipo_novidade
ON CONFLICT (id_tipo)
DO
  UPDATE
  SET
    texto_evento = EXCLUDED.texto_evento,
    texto_resumo = EXCLUDED.texto_resumo;

DROP TABLE temp_tipo_novidade;
COMMIT;
