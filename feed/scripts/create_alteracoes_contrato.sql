DROP TABLE IF EXISTS alteracoes_contrato;

CREATE TABLE IF NOT EXISTS "alteracoes_contrato" (    
    "id_alteracoes_contrato" VARCHAR(20),
    "id_contrato" VARCHAR(20),
    "id_orgao" VARCHAR(20),
    "ano_licitacao" INTEGER,
    "nr_licitacao" VARCHAR(20),
    "cd_tipo_modalidade" VARCHAR(3),
    "nr_contrato" VARCHAR(20),
    "ano_contrato" INTEGER,
    "tp_instrumento_contrato" VARCHAR(1),
    "id_evento_contrato" VARCHAR(10),
    "cd_tipo_operacao" VARCHAR(3),
    "vigencia_novo_contrato" INTEGER,
    "vl_acrescimo" NUMERIC(18, 2),
    "vl_reducao" NUMERIC(18, 2),
    "pc_acrescimo" NUMERIC(18, 2),
    "pc_reducao" VARCHAR(8),
    "ds_justificativa" TEXT,
    "tipo_operacao_alteracao" VARCHAR(60),
    FOREIGN KEY ("id_contrato") REFERENCES contrato ("id_contrato"),
    PRIMARY KEY("id_alteracoes_contrato")
);
