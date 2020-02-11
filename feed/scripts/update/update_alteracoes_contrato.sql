-- ALTERACOES CONTRATO
BEGIN;
CREATE TEMP TABLE temp_alteracoes_contrato AS SELECT * FROM alteracoes_contrato LIMIT 0;

\copy temp_alteracoes_contrato FROM '/data/bd/info_alteracao_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO alteracoes_contrato 
SELECT *
FROM temp_alteracoes_contrato
ON CONFLICT (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato,
id_evento_contrato,cd_tipo_operacao)
DO
  UPDATE
  SET    
    vigencia_novo_contrato = EXCLUDED.vigencia_novo_contrato,
    vl_acrescimo = EXCLUDED.vl_acrescimo,
    vl_reducao = EXCLUDED.vl_reducao,
    pc_acrescimo = EXCLUDED.pc_acrescimo,
    pc_reducao = EXCLUDED.pc_reducao,
    ds_justificativa = EXCLUDED.ds_justificativa,
    tipo_operacao_alteracao = EXCLUDED.tipo_operacao_alteracao;

DROP TABLE temp_alteracoes_contrato;
COMMIT;
