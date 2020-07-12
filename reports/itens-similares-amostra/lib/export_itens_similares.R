library(tidyverse)
source(here::here("reports/itens-similares-amostra/lib/functions.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-u", "--url"), type="character", default="http://ta-na-mesa_backend_1:5000/api/itensContrato/similares",
              help="URL para o endpoint de itens similares na API [default= %default]", metavar="character"),
  make_option(c("-n", "--n_itens"), type="integer", default=1000,
              help="Número de itens usados para pesquisa de itens similares [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

url = opt$url
n_itens <- opt$n_itens

message("Iniciando processamento...")

itens <- processa_itens_similares(url, n_itens)

write_csv(itens, here::here("reports/itens-similares-amostra/data/itens_similares.csv"))

message("Concluído!")
