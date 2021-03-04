#' @title Busca dados das licitações do TCE-PE
#' @param tce_bd_con Conexão com o banco do TCE-PE
#' @param limite_inferior Data limite inferior do ano das licitações
#' @param limite_superior Data limite superior do ano das licitações
#' @return Dataframe contendo informações sobre as licitações
#' @rdname fetch_licitacoes_pe
#' @examples
#' licitacoes_pe <- fetch_licitacoes_pe(tce_bd_con)
fetch_licitacoes_pe <- function(tce_bd_con, limite_inferior = 2017, limite_superior = 2020) {
  
  licitacoes <- tibble::tibble()
  tryCatch({
    licitacoes <- DBI::dbGetQuery(tce_bd_con, sprintf(
      "SELECT * FROM SCA_LicitacoesDetalhes WHERE AnoProcesso >= %d AND AnoProcesso <= %d;", limite_inferior, limite_superior))
  }, 
  error = function(e) print(paste0("Erro ao buscar dados das licitações (SQL Server): ", e))
  )
  
  return(licitacoes)
}

#' @title Busca dados dos contratos do TCE-PE
#' @param tce_bd_con Conexão com o banco do TCE-PE
#' @param limite_inferior Data limite inferior do ano dos contratos
#' @param limite_superior Data limite superior do ano dos contratos
#' @return Dataframe contendo informações sobre dos contratos
#' @rdname fetch_contratos_pe
#' @examples
#' contratos_pe <- fetch_contratos_pe(tce_bd_con)
fetch_contratos_pe <- function(tce_bd_con, limite_inferior = 2017, limite_superior = 2020) {
  
  contratos <- tibble::tibble()
  tryCatch({
    contratos <- DBI::dbGetQuery(tce_bd_con, sprintf(
      "SELECT * FROM Contratos WHERE AnoContrato >= %d AND AnoContrato <= %d;", limite_inferior, limite_superior))
  }, 
  error = function(e) print(paste0("Erro ao buscar dados dos contratos (SQL Server): ", e))
  )
  
  return(contratos)
}

#' @title Busca dados dos aditivos dos contratos do TCE-PE
#' @param tce_bd_con Conexão com o banco do TCE-PE
#' @param limite_inferior Data limite inferior do ano dos contratos
#' @param limite_superior Data limite superior do ano dos contratos
#' @return Dataframe contendo informações sobre aditivos dos contratos
#' @rdname fetch_aditivos_pe
#' @examples
#' aditivos_contratos_pe <- fetch_aditivos_pe(tce_bd_con)
fetch_aditivos_pe <- function(tce_bd_con, limite_inferior = 2017, limite_superior = 2020) {
  
  aditivos <- tibble::tibble()
  tryCatch({
    aditivos <- DBI::dbGetQuery(tce_bd_con, sprintf(
      "SELECT * FROM TERMOADITIVO WHERE AnoContrato >= %d AND AnoContrato <= %d;", limite_inferior, limite_superior))
  }, 
  error = function(e) print(paste0("Erro ao buscar dados dos aditivos (SQL Server): ", e))
  )
  
  return(aditivos)
}

#' @title Busca dados dos municípios do TCE-PE
#' @param tce_bd_con Conexão com o banco do TCE-PE
#' @return Dataframe contendo informações sobre os municipios
#' @rdname fetch_municipios_pe
#' @examples
#' municipios_pe <- fetch_municipios_pe(tce_bd_con)
fetch_municipios_pe <- function(tce_bd_con) {
  
  municipios <- tibble::tibble()
  tryCatch({
    municipios <- DBI::dbGetQuery(tce_bd_con, "SELECT * FROM MUNICIPIO")
  }, 
  error = function(e) print(paste0("Erro ao buscar dados dos esquemas do Banco do TCE-PE: ", e))
  )
  
  return(municipios)
}

#' @title Busca dados das unidades gestoras estaduais do TCE-PE
#' @param tce_bd_con Conexão com o banco do TCE-PE
#' @return Dataframe contendo informações sobre as unidades gestoras
#' @rdname fetch_unidades_gestoras_estaduais_pe
#' @examples
#' ugs_estaduais <- fetch_unidades_gestoras_estaduais_pe(tce_bd_con)
fetch_unidades_gestoras_estaduais_pe <- function(tce_bd_con) {
  
  unidades_gestoras <- tibble::tibble()
  tryCatch({
    unidades_gestoras <- DBI::dbGetQuery(tce_bd_con, "SELECT * FROM SCA_UJsEstaduais")
  }, 
  error = function(e) print(paste0("Erro ao buscar dados das unidades gestoras do Banco do TCE-PE: ", e))
  )
  
  return(unidades_gestoras)
}

#' @title Busca dados das unidades gestoras municipais do TCE-PE
#' @param tce_bd_con Conexão com o banco do TCE-PE
#' @return Dataframe contendo informações sobre as unidades gestoras
#' @rdname fetch_unidades_gestoras_municipais_pe
#' @examples
#' ugs_municipais <- fetch_unidades_gestoras_municipais_pe(tce_bd_con)
fetch_unidades_gestoras_municipais_pe <- function(tce_bd_con) {
  
  unidades_gestoras <- tibble::tibble()
  tryCatch({
    unidades_gestoras <- DBI::dbGetQuery(tce_bd_con, "SELECT * FROM SCA_UJsMunicipais")
  }, 
  error = function(e) print(paste0("Erro ao buscar dados das unidades gestoras do Banco do TCE-PE: ", e))
  )
  
  return(unidades_gestoras)
}

#' @title Busca dados dos fornecedores do TCE-PE
#' @param tce_bd_con Conexão com o banco do TCE-PE
#' @return Dataframe contendo informações dos fornecedores
#' @rdname fetch_fornecedores_pe
#' @examples
#' fornecedores <- fetch_fornecedores_pe(tce_bd_con)
fetch_fornecedores_pe <- function(tce_bd_con) {
  
  fornecedores <- tibble::tibble()
  tryCatch({
    fornecedores <- DBI::dbGetQuery(tce_bd_con, "SELECT * FROM SCA_Pessoa")
  }, 
  error = function(e) print(paste0("Erro ao buscar dados dos fornecedores do Banco do TCE-PE: ", e))
  )
  
  return(fornecedores)
}

#' @title Busca dados dos itens do TCE-PE
#' @param tce_bd_con Conexão com o banco do TCE-PE
#' @return Dataframe contendo informações dos itens
#' @rdname fetch_itens_pe
#' @examples
#' itens <- fetch_itens_pe(tce_bd_con)
fetch_itens_pe <- function(tce_bd_con) {
  
  itens <- tibble::tibble()
  tryCatch({
    itens <- DBI::dbGetQuery(tce_bd_con, "SELECT * FROM SCA_ContratoItemObjeto")
  }, 
  error = function(e) print(paste0("Erro ao buscar dados dos itens do Banco do TCE-PE: ", e))
  )
  
  return(itens)
}

#' @title Busca dados das tabelas do banco TCE-PE SQLServer
#' @param tce_bd_con Conexão com o banco do TCE-PE
#' @return Dataframe contendo informações das tabelas do banco
#' @rdname lista_esquemas_tce_pe
#' @examples
#' info_tabelas <- lista_esquemas_tce_pe(tce_bd_con)
lista_esquemas_tce_pe <- function(tce_bd_con) {
  
  esquemas <- tibble::tibble()
  tryCatch({
    esquemas <- DBI::dbGetQuery(tce_bd_con, "SELECT * FROM sys.Tables GO")
  }, 
  error = function(e) print(paste0("Erro ao buscar dados dos esquemas do Banco do TCE-PE: ", e))
  )
  
  return(esquemas)
}
