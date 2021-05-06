
DROP TABLE IF EXISTS itens_unicos_similaridade;

CREATE TABLE IF NOT EXISTS itens_unicos_similaridade(
    "id_item_contrato" serial primary key, 
    "ds_item" TEXT, 
    "sg_unidade_medida" VARCHAR(200), 
    "ds_1" TEXT, 
    "ds_2" TEXT, 
    "ds_3" TEXT, 
    "ids_itens_contratos" varchar[]
);
