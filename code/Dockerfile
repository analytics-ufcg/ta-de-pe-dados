FROM rocker/tidyverse:3.6.1

WORKDIR /app

## Cria arquivo para indicar raiz do repositório (Usado pelo pacote here)
RUN touch .here

## Instala dependências
RUN R -e "install.packages(c('here', 'janitor', 'purrr'), repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('RPostgres', repos='http://cran.rstudio.com/')"
RUN Rscript -e 'devtools::install_version("tidyselect", version = "1.1.0", repos = "http://cran.rstudio.com/")'

EXPOSE 8787