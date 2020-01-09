library(tidyverse)
library(here)
source(here::here("code/ideb/fetch_ideb.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  
  make_option(c("-o", "--outIdeb"), type="character", default=here::here("data/ideb/ideb.csv"),
              help="nome do arquivo de saída para os dados do IDEB [default= %default]", metavar="character")
)

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output <- opt$outIdeb

message("Iniciando processamento...")
fetch_ideb_all_data()

dados_ideb <- process_ideb_all_data()


message(paste0("Salvando os dados em: ", output))
readr::write_csv(dados_ideb, output)

message("Concluído!")
