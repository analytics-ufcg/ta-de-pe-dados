-- FORNECEDOR
BEGIN;
CREATE TEMP TABLE temp_fornecedor AS SELECT * FROM fornecedor LIMIT 0;

\copy temp_fornecedor FROM '/data/bd/info_fornecedores_contrato.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO fornecedor 
SELECT *
FROM temp_fornecedor
ON CONFLICT (nr_documento)
DO
  UPDATE
  SET  
    nm_pessoa = EXCLUDED.nm_pessoa,
    tp_pessoa = EXCLUDED.tp_pessoa,
    total_de_contratos = EXCLUDED.nm_pessoa,
    data_primeiro_contrato = EXCLUDED.nm_pessoa;

DROP TABLE temp_fornecedor;
COMMIT;