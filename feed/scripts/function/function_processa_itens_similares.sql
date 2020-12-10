CREATE EXTENSION IF NOT EXISTS pg_trgm;

do $$
declare
    e record;
    found_id int;
begin
    truncate itens_unicos_similaridade;
    for e in (select * from item_contrato) loop
        select min(id_item_contrato)
        into found_id
        from itens_unicos_similaridade u
        where (similarity(u.ds_2, e.ds_2) + similarity(u.ds_3, e.ds_3))/2 > 0.50;
        if found_id is not null then
            update itens_unicos_similaridade
            set ids_itens_contratos = ids_itens_contratos || e.id_item_contrato
            where id_item_contrato = found_id;
        else
            insert into itens_unicos_similaridade (ds_item, sg_unidade_medida, ds_1, ds_2, ds_3, ids_itens_contratos)
            values (e.ds_item,e.sg_unidade_medida, e.ds_1, e.ds_2, e.ds_3, array[e.id_item_contrato]);
        end if;
    end loop;
end $$;