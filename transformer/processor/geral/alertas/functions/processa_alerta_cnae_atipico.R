library(tidyverse)
library(futile.logger)
source(here::here("transformer/utils/read_utils.R"))

#' Processa alertas referentes aos CNAEs principais atípicos no fornecimento de determinados itens
#' 
#' @param anos Array com os anos para recuperação dos contratos. Exemplo: c(2018, 2019, 2020)
#' @return Dataframe com alertas para CNAEs atípicos
#' 
#' @examples 
#' alertas <- processa_alerta_cnae_atipico("merenda")
processa_alerta_cnae_atipico <- function(filtro) {
    flog.info("Processando alertas de itens atípicos por atividade econômica...")
    LIMITE_MIN_PROP_CNAE = .01
    flog.info(str_glue("Limite de corte para a proporção de venda de um produto { LIMITE_MIN_PROP_CNAE }"))
    
    cnaes_itens_fornecedor <- processa_itens_cnaes_fornecedores()
    
    if (nrow(cnaes_itens_fornecedor) == 0) {
        return(tibble())
    }
    
    flog.info(str_glue("Tabela com casos de cnaes para serem ignorados na geração do alerta"))
    cnaes_falsos_positivos <- read_csv(here::here("transformer/processor/geral/alertas/data/cnaes_desconsiderados_produtos.csv"),
                                       col_types = cols(.default = col_character())) %>% 
        filter(assunto %in% c(filtro, "geral")) %>% 
        distinct(id_estado, id_cnae)
    print(cnaes_falsos_positivos)
    
    cnaes_atipicos_data <- cnaes_itens_fornecedor %>% 
        group_by(id_estado, id_contrato, razao_social, nr_documento_contratado, item_class) %>% 
        arrange(desc(prop_grupo_total_item)) %>% 
        mutate(max_prop_total_item = max(prop_grupo_total_item)) %>% 
        ungroup() %>% 
        filter(is_cnae_fiscal == 't') %>% 
        mutate(id_tipo = 2) %>% 
        mutate(nr_documento = nr_documento_contratado) %>% 
        mutate(atipico = max_prop_total_item <= LIMITE_MIN_PROP_CNAE) %>% 
        filter(atipico) %>% 
        anti_join(cnaes_falsos_positivos, by = c("id_estado", "id_cnae"))
    
    flog.info(str_glue("{ cnaes_atipicos_data %>% nrow } casos de itens atípicos detectados"))
    
    cnaes_atipicos_alt <- cnaes_atipicos_data %>% 
        generate_hash_id(c("id_contrato", "id_item_contrato", "id_tipo"), ITEM_ATIPICO) %>% 
        generate_hash_id(c("id_tipo", "nr_documento", "id_contrato"), ALERTA_ID) %>% 
        dplyr::select(id_item_atipico, id_alerta, id_item_contrato, id_contrato, id_estado,
                      nr_documento, id_tipo, ds_item, total_vendas_item = qt_total_item, 
                      n_vendas_semelhantes = qt_total_item_grupo, perc_vendas_semelhantes = prop_grupo_total_item) 
    
    contratos_itens_atipicos <- cnaes_atipicos_alt %>%
        group_by(id_estado, id_contrato, nr_documento, id_tipo) %>% 
        summarise(total_itens_atipicos=n(), .groups = 'drop') %>% 
        arrange(desc(total_itens_atipicos)) %>% 
        mutate(info=ifelse(total_itens_atipicos != 1, 
                           paste0("A empresa forneceu ", total_itens_atipicos, 
                                  " produtos que não são comuns com base em suas atividades econômicas declaradas na Receita Federal"),
                           paste0("A empresa forneceu ", total_itens_atipicos, 
                                  " produto que não é comum com base em suas atividades econômicas declaradas na Receita Federal"))) %>% 
        ungroup() %>% 
        select(nr_documento, id_contrato, id_tipo, info)
    
    flog.info(str_glue("{ contratos_itens_atipicos %>% nrow } alertas de produtos atípicos"))
    
    readr::write_csv(cnaes_atipicos_alt %>% select(-c(nr_documento, id_tipo, id_estado)), 
                     here::here("data/bd/itens_atipicos.csv"))
    
    return(contratos_itens_atipicos)
}

#' Agrupa todos os produtos e atividades econômicas dos fornecedores. 
#'
#' @return dataframe com todos os produtos fornecidos por determinadas atividades econômicas
#' 
#' @examples 
#' cnaes_itens_forcenedor <- .processa_itens_cnaes_fornecedores()
processa_itens_cnaes_fornecedores <- function() {
    flog.info("Processando agrupamento de itens e cnaes")
    limite_min_itens <- read_csv(here::here("transformer/processor/geral/alertas/data/limite_itens_estados.csv"),
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

    dados_cadastrais_processados <- tryCatch({
        read_dados_cadastrais_processados() %>% 
            select(cnpj, razao_social, nome_fantasia, cnae_fiscal) 
    }, error = function(e) {
        flog.error("Ocorreu um erro ao ler dados cadastrais")
        flog.error(e)
        return(tibble())
    })
    
    if (nrow(dados_cadastrais_processados) == 0) {
        return(tibble())
    }
    
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
