library(tidyverse)
library(futile.logger)

source(here::here("fetcher/inidoneos/fetch_cadastro_inidoneos.R"))

.HELP <- "Rscript export_cadastro_inidoneos.R"

output_path <- here::here("data/inidoneos/")
dir.create(output_path)

data_atual <- gsub("-", "", Sys.Date())
ceis <- fetch_ceis_github(data_atual)
cnep <- fetch_cnep_github(data_atual)

if (nrow(ceis) > 0) {
  write_csv(ceis, paste0(output_path, "ceis.csv"))
} else {
  flog.info("Os dados do CEIS não foram atualizados.")
}

if (nrow(cnep) > 0) {
  write_csv(cnep, paste0(output_path, "cnep.csv"))
} else {
  flog.info("Os dados do CNEP não foram atualizados.")
}

flog.info("Fetcher do cadastro de inidôneos finalizou. Verifique as mensagens de log.")
