library(magrittr)
library(here)

source(here::here("fetcher/config/constants.R"))
source(here::here("fetcher/estados/PE/tce/DAO_TCE_PE.R"))

tce_pe_con <- NULL

.HELP <- "Rscript fetch_dados_tce_pe.R --data_inicio <2017> --data_fim <2020>"

#' @title Obtém argumentos passados por linha de comando
get_args <- function() {
  args = commandArgs(trailingOnly=TRUE)
  
  option_list = list(
    optparse::make_option(c("--data_inicio"),
                          type="integer",
                          default=2018,
                          help="Data inicial da seleção (para licitações e contratos).",
                          metavar="integer"),
    optparse::make_option(c("--data_fim"),
                          type="integer",
                          default=2020,
                          help="Data final da seleção (para licitações e contratos).",
                          metavar="integer")
  );
  
  opt_parser <- optparse::OptionParser(option_list = option_list, usage = .HELP)
  
  opt <- optparse::parse_args(opt_parser)
  return(opt);
}

args <- get_args()

data_inicio <- args$data_inicio
data_fim <- args$data_fim

tryCatch(
  {tce_pe_con <- DBI::dbConnect(odbc::odbc(),
                                Driver = "ODBC Driver 17 for SQL Server",
                                Database = SQLSERVER_TCE_PE_DATABASE,
                                Server = paste0(SQLSERVER_TCE_PE_HOST,",", SQLSERVER_TCE_PE_PORT),
                                UID = SQLSERVER_TCE_PE_USER,
                                PWD = SQLSERVER_TCE_PE_PASS)
  cat("-  Acesso ao TCE-PE criado com sucesso!\n")
  }, 
  error = function(e) stop(paste0("Erro ao tentar se conectar ao Banco do TCE-PE: ",e))
)

tabelas <- lista_esquemas_tce_pe(tce_pe_con)

municipios <- fetch_municipios_pe(tce_pe_con)

licitacoes <- fetch_licitacoes_pe(tce_pe_con, data_inicio, data_fim)

contratos <- fetch_contratos_pe(tce_pe_con, data_inicio, data_fim)

aditivos <- fetch_aditivos_pe(tce_pe_con, data_inicio, data_fim)

ugs_estaduais <- fetch_unidades_gestoras_estaduais_pe(tce_pe_con)

ugs_municipais <- fetch_unidades_gestoras_municipais_pe(tce_pe_con)

fornecedores <- fetch_fornecedores_pe(tce_pe_con)

itens <- fetch_itens_pe(tce_pe_con)

output_path <- here::here("data/tce_pe/")

if (!dir.exists(output_path)){
  dir.create(output_path, recursive = TRUE)
}

readr::write_csv(municipios, paste0(output_path, "municipios.csv"))
readr::write_csv(licitacoes, paste0(output_path,"licitacoes.csv"))
readr::write_csv(contratos, paste0(output_path,"contratos.csv"))
readr::write_csv(aditivos, paste0(output_path,"aditivos.csv"))
readr::write_csv(ugs_estaduais, paste0(output_path,"ugs_estaduais.csv"))
readr::write_csv(ugs_municipais, paste0(output_path,"ugs_municipais.csv"))
readr::write_csv(fornecedores, paste0(output_path,"fornecedores.csv"))
readr::write_csv(itens, paste0(output_path,"itens.csv"))
