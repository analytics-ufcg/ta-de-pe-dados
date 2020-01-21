-- LICITANTE
BEGIN;
CREATE TEMP TABLE temp_licitante AS SELECT * FROM licitante LIMIT 0;

\copy temp_licitante FROM '/data/bd/info_licitante.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO licitante 
(id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, tp_documento_licitante, 
nr_documento_licitante, tp_documento_repres, nr_documento_repres, tp_condicao, 
tp_resultado_habilitacao, bl_beneficio_micro_epp, licitacao_id, licitante_id)
SELECT id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, tp_documento_licitante, 
nr_documento_licitante, tp_documento_repres, nr_documento_repres, tp_condicao, 
tp_resultado_habilitacao, bl_beneficio_micro_epp, licitacao_id, licitante_id
FROM temp_licitante
ON CONFLICT (id_orgao, nr_licitacao, ano_licitacao, cd_tipo_modalidade, tp_documento_licitante, 
nr_documento_licitante)
DO
  UPDATE
  SET  
    tp_documento_repres = EXCLUDED.tp_documento_repres,
    nr_documento_repres = EXCLUDED.nr_documento_repres,
    tp_condicao = EXCLUDED.tp_condicao,
    tp_resultado_habilitacao = EXCLUDED.tp_resultado_habilitacao,
    bl_beneficio_micro_epp = EXCLUDED.bl_beneficio_micro_epp,
    licitacao_id = EXCLUDED.licitacao_id,
    licitante_id = EXCLUDED.licitante_id;

DROP TABLE temp_licitante;
COMMIT;