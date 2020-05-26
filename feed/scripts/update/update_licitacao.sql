-- LICITACAO
BEGIN;
CREATE TEMP TABLE temp_licitacao AS SELECT * FROM licitacao LIMIT 0;

\copy temp_licitacao FROM '/data/bd/info_licitacao.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO licitacao 
SELECT *
FROM temp_licitacao
ON CONFLICT (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade)
DO
  UPDATE
  SET  
    id_estado = EXCLUDED.id_estado,
    nm_orgao = EXCLUDED.nm_orgao,
    permite_subcontratacao = EXCLUDED.permite_subcontratacao,
    tp_fornecimento = EXCLUDED.tp_fornecimento,    
    descricao_objeto = EXCLUDED.descricao_objeto,
    vl_estimado_licitacao = EXCLUDED.vl_estimado_licitacao,
    data_abertura = EXCLUDED.data_abertura,
    data_homologacao = EXCLUDED.data_homologacao,
    data_adjudicacao = EXCLUDED.data_adjudicacao,
    vl_homologado = EXCLUDED.vl_homologado,
    tp_licitacao = EXCLUDED.tp_licitacao,
    merenda = EXCLUDED.merenda,
    tipo_licitacao = EXCLUDED.tipo_licitacao,
    tipo_modalidade_licitacao = EXCLUDED.tipo_modalidade_licitacao;

DROP TABLE temp_licitacao;
COMMIT;
