library(tidyverse)
library(here)
source(here::here("code/censo_escolar/fetch_censo_escolar_inep.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  
  make_option(c("-o", "--outCenso"), type="character", default=here::here("data/censo_escolar/censo_escolar_2018.csv"),
              help="nome do arquivo de saída para os dados do censo escolar [default= %default]", metavar="character")
  )

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output <- opt$outCenso

message("Iniciando processamento...")
dados_censo <- fetch_censo_escolar_all()


message(paste0("Salvando os dados em: ", output))
readr::write_csv(dados_censo, output)

message("Concluído!")
