-- ITEM CONTRATO
BEGIN;
CREATE TEMP TABLE temp_item_contrato AS SELECT * FROM item_contrato LIMIT 0;

\copy temp_item_contrato FROM '/data/bd/info_item_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO item_contrato 
SELECT *
FROM temp_item_contrato
ON CONFLICT (id_orgao, ano_licitacao, nr_licitacao, cd_tipo_modalidade, nr_contrato, ano_contrato, tp_instrumento_contrato,
nr_lote, nr_item)
DO
  UPDATE
  SET
    qt_itens_contrato = EXCLUDED.qt_itens_contrato,
    vl_item_contrato = EXCLUDED.vl_item_contrato,
    vl_total_item_contrato = EXCLUDED.vl_total_item_contrato;

DROP TABLE temp_item_contrato;
COMMIT;