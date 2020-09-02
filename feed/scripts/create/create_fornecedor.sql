DROP TABLE IF EXISTS fornecedor;

CREATE TABLE IF NOT EXISTS "fornecedor" ( 
    "nr_documento" VARCHAR(14),
    "nm_pessoa" VARCHAR(500),
    "tp_pessoa" VARCHAR(4),
    "total_de_contratos" INTEGER,
    "data_primeiro_contrato" DATE,
    PRIMARY KEY("nr_documento")
);
