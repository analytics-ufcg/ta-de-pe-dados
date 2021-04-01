library(tidyverse)
library(futile.logger)
source(here::here("transformer/utils/read_utils.R"))

#' Agrupa todos os produtos e atividades econômicas dos fornecedores. 
#'
#' @return dataframe com todos os produtos fornecidos por determinadas atividades econômicas
#' 
#' @examples 
#' cnaes_itens_forcenedor <- .processa_itens_cnaes_fornecedores()
processa_itens_cnaes_fornecedores <- function() {
    flog.info("Processando agrupamento de itens e cnaes")
    limite_min_itens <- read_csv(here::here("transformer/processor/geral/alertas/limite_itens_estados.csv"),
                                 col_types = cols(id_estado = "c"))
    flog.info("Tabela com constantes de mínimo de itens por classe para filtro")
    print(limite_min_itens)

    itens_unicos_similaridade <- read_itens_similares_processados() %>% 
        dplyr::select (-c(id_item_contrato))

    flog.info(str_glue("{itens_unicos_similaridade %>% nrow()} classes de itens similares usados"))

    contratos_processados <- read_contratos_processados() %>% 
        filter(nchar(nr_documento_contratado) == 14) %>% 
        select(id_contrato, nr_documento_contratado, nr_contrato, ano_contrato, nm_orgao)
    flog.info(str_glue("{contratos_processados %>% nrow()} contratos processados com cnpj como fornecedor"))
    
    itens_contratos_processados <- read_itens_contrato_processados()
    flog.info(str_glue("{itens_contratos_processados %>% nrow()} itens de contratos processados"))

    dados_cadastrais_processados <- read_dados_cadastrais_processados() %>% 
        select(cnpj, razao_social, nome_fantasia, cnae_fiscal) 
    
    cnaes_processados <- read_cnaes_processados() %>% 
        select(id_cnae, nm_cnae, nm_classe, nm_grupo, nm_divisao, nm_secao)
    
    cnaes_secundarios_processados <- read_cnaes_secundarios_processados() %>% 
        select(cnpj, id_cnae) 
    
    itens_contrato <- itens_contratos_processados %>%  
        select(id_estado, id_item_contrato, id_contrato, id_item_licitacao, ds_item, ds_1, ds_2, ds_3) %>% 
        left_join(contratos_processados, by = c("id_contrato"))
    
    itens_contrato_info <- itens_contrato %>% left_join(dados_cadastrais_processados, by = c("nr_documento_contratado" = "cnpj"))
    
    itens_contrato_info_cnae_fiscal <- itens_contrato_info %>% 
        mutate(id_cnae=cnae_fiscal) %>% 
        select(-c(cnae_fiscal)) %>% 
        mutate(is_cnae_fiscal="t")
    
    flog.info(str_glue("{itens_contrato_info_cnae_fiscal %>% nrow()} itens de contrato com cnae fiscal"))
    
    cnae_secundario_itens <- cnaes_secundarios_processados %>%
        left_join(itens_contrato_info, by = c("cnpj" = "nr_documento_contratado")) %>% 
        filter(!is.na(id_item_contrato)) %>% 
        select(-c(cnae_fiscal)) %>% 
        mutate(nr_documento_contratado=cnpj) %>% 
        select(-c(cnpj)) %>% 
        mutate(is_cnae_fiscal="f") %>% 
        left_join(cnaes_processados, by = c("id_cnae")) %>% 
        filter(!is.na(nm_cnae))
    
    flog.info(str_glue("{cnae_secundario_itens %>% nrow()} linhas são retornadas quando se cruzam cnaes secundários",
                       " e itens de contrato"))
    
    cnae_fiscal_itens <- itens_contrato_info_cnae_fiscal %>% left_join(cnaes_processados, by = c("id_cnae"))%>% 
        filter(!is.na(nm_cnae))
    
    all_cnaes <- bind_rows (cnae_secundario_itens, cnae_fiscal_itens) %>% 
        filter(!is.na(nm_cnae))
    
    flog.info(str_glue("{all_cnaes %>% nrow()} linhas no mapeamento cnae(fiscal e secundário) para itens de contrato"))
    
    itens_separated <- separate_rows(itens_unicos_similaridade, ids_itens_contratos, convert = TRUE) %>% 
        mutate (id_item_contrato = ids_itens_contratos) %>% 
        select (-c(ids_itens_contratos)) %>% 
        filter (id_item_contrato != "") %>% 
        mutate (item_class = ds_item)
    
    flog.info(str_glue("{itens_separated %>% nrow()} itens de contrato mapeados para uma classe de item"))
    
    cnae_fiscal_itens_unicos <- cnae_fiscal_itens %>% 
        left_join(itens_separated %>% select(c(id_item_contrato, item_class)), by="id_item_contrato")
    
    cnae_all_itens_unicos <- all_cnaes %>%
        left_join(itens_separated %>% select(c(id_item_contrato, item_class)), by="id_item_contrato")
    
    total_item_cnae_df <- cnae_fiscal_itens_unicos %>% 
        select(id_estado, item_class, nm_grupo) %>% 
        group_by(id_estado, item_class, nm_grupo) %>% 
        mutate(qt_total_item_grupo = n()) %>%
        ungroup() %>% 
        distinct() %>% 
        arrange(desc(qt_total_item_grupo))
    
    total_item_df <- cnae_fiscal_itens_unicos %>% 
        select(id_estado, item_class) %>% 
        group_by(id_estado, item_class) %>% 
        mutate(qt_total_item = n()) %>%
        ungroup() %>% 
        distinct() %>% 
        arrange(desc(qt_total_item))
    
    cnaes_itens_fornecedor <- cnae_all_itens_unicos %>% 
        left_join(total_item_df, by=c("item_class", "id_estado")) %>%
        left_join(total_item_cnae_df, by=c("id_estado", "nm_grupo", "item_class")) %>% 
        mutate(prop_grupo_total_item= qt_total_item_grupo/qt_total_item) %>%
        select(id_cnae, id_estado, id_item_contrato, id_contrato, ds_item, nr_contrato, ano_contrato, nm_orgao, 
               razao_social, nr_documento_contratado, is_cnae_fiscal, 
               nm_grupo, nm_divisao, item_class, qt_total_item, 
               qt_total_item_grupo, prop_grupo_total_item) %>%
        mutate_all(list(~ ifelse(is.na(.), 0, .))) %>% 
        left_join(limite_min_itens, by = c("id_estado")) %>% 
        filter(qt_total_item >= limite_minimo_itens)
    
    flog.info(
        str_glue(
            "{cnaes_itens_fornecedor %>% nrow()} linhas retornadas no dataframe que mapeia ",
            "cnaes para itens de contrato. ",
            "Foi filtrado pelo número mínimo de itens da classe por estado."
        )
    )
    
    return(cnaes_itens_fornecedor)  
}
