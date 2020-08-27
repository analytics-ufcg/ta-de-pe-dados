-- CONTRATO
BEGIN;
CREATE TEMP TABLE temp_contrato AS SELECT * FROM contrato LIMIT 0;

\copy temp_contrato FROM '/data/bd/info_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO contrato 
SELECT *
FROM temp_contrato
ON CONFLICT (id_contrato)
DO
  UPDATE
  SET  
    nm_orgao = EXCLUDED.nm_orgao,
    nr_processo = EXCLUDED.nr_processo,
    ano_processo = EXCLUDED.ano_processo,
    tp_documento_contratado = EXCLUDED.tp_documento_contratado,
    nr_documento_contratado = EXCLUDED.nr_documento_contratado,
    dt_inicio_vigencia = EXCLUDED.dt_inicio_vigencia,
    dt_final_vigencia = EXCLUDED.dt_final_vigencia,
    vl_contrato = EXCLUDED.vl_contrato,
    contrato_possui_garantia = EXCLUDED.contrato_possui_garantia,
    vigencia_original_do_contrato = EXCLUDED.vigencia_original_do_contrato,
    descricao_objeto_contrato = EXCLUDED.descricao_objeto_contrato,
    justificativa_contratacao = EXCLUDED.justificativa_contratacao,
    obs_contrato = EXCLUDED.obs_contrato,
    tipo_instrumento_contrato = EXCLUDED.tipo_instrumento_contrato;

DROP TABLE temp_contrato;
COMMIT;