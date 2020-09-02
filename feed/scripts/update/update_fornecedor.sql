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
    total_de_contratos = EXCLUDED.total_de_contratos,
    data_primeiro_contrato = EXCLUDED.data_primeiro_contrato;

DROP TABLE temp_fornecedor;
COMMIT;