
DROP TABLE IF EXISTS itens_unicos_similaridade;

CREATE TABLE IF NOT EXISTS itens_unicos_similaridade(
    "id_item_contrato" serial primary key, 
    "ds_item" VARCHAR(2000), 
    "sg_unidade_medida" VARCHAR(200), 
    "ds_1" VARCHAR(2000), 
    "ds_2" VARCHAR(2000), 
    "ds_3" VARCHAR(2000), 
    "ids_itens_contratos" varchar[]
);
