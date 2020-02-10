-- ITEM
BEGIN;
CREATE TEMP TABLE temp_item AS SELECT * FROM item LIMIT 0;

\copy temp_item FROM '/data/bd/info_item_licitacao.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO item 
SELECT *
FROM temp_item
ON CONFLICT (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_lote, nr_item)
DO
  UPDATE
  SET  
    ds_item = EXCLUDED.ds_item,
    qt_itens_licitacao = EXCLUDED.qt_itens_licitacao,
    sg_unidade_medida = EXCLUDED.sg_unidade_medida,
    vl_unitario_estimado = EXCLUDED.vl_unitario_estimado,    
    vl_total_estimado = EXCLUDED.vl_total_estimado;

DROP TABLE temp_item;
COMMIT;
