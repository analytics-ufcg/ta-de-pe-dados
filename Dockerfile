FROM rocker/tidyverse:3.6.1

WORKDIR /app
RUN chmod 755 /app

## Cria arquivo para indicar raiz do repositório (Usado pelo pacote here)
RUN touch .here

RUN sudo apt -y install openssh-server

##Instala drivers do SQLServer
RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
        apt-transport-https \
        curl \
        gnupg \
        unixodbc-dev \
 && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
 && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
 && apt-get update \
 && ACCEPT_EULA=Y apt-get install --yes --no-install-recommends msodbcsql17 \
 && install2.r odbc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/*
## Finaliza instalacao dos drivers SQLServers


## Instala dependências
RUN R -e "install.packages(c('here', 'janitor', 'purrr', 'optparse', 'odbc', 'DBI'), repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('RPostgres', repos='http://cran.rstudio.com/')"
RUN Rscript -e 'devtools::install_version("tidyselect", version = "1.1.0", repos = "http://cran.rstudio.com/")'
RUN Rscript -e "install.packages('futile.logger', repos='http://cran.rstudio.com/')"
RUN Rscript -e "install.packages('rollbar', repos='http://cran.rstudio.com/')"
RUN Rscript -e 'devtools::install_version("testthat", version = "3.0.4", repos = "http://cran.rstudio.com/")'

EXPOSE 8787
