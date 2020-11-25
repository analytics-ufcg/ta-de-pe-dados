-- ORGAO
BEGIN;
CREATE TEMP TABLE temp_orgao AS SELECT * FROM orgao LIMIT 0;

\copy temp_orgao FROM '/data/bd/info_orgaos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO orgao
SELECT *
FROM temp_orgao
ON CONFLICT (id_orgao)
DO
  UPDATE
  SET
    nm_orgao = EXCLUDED.nm_orgao,
    sigla_orgao = EXCLUDED.sigla_orgao,
    esfera = EXCLUDED.esfera,
    home_page = EXCLUDED.home_page,
    nome_municipio = EXCLUDED.nome_municipio,,
    cd_municipio_ibge = EXCLUDED.cd_municipio_ibge,
    nome_entidade = EXCLUDED.nome_entidade,
    sigla_estado = EXCLUDED.sigla_estado;

DROP TABLE temp_orgao;
COMMIT;
