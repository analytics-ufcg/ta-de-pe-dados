# Ta na mesa

Repositório de acesso a dados de licitações, empenhos e contratos do Tribunal de Contas do Estado do Rio Grande do Sul.

Este readme é dividido em duas partes principais. O serviço que baixa os dados do TSE (**Serviço crawler**) e o serviço que processa os dados do TSE para o formato usado no tá na mesa (**Serviço r-process**). As duas seções seguintes explicam o uso destes serviços.

## Para baixar os dados usando Docker - Serviço crawler

O Docker irá facilitar a instalação dasa depedências e a configuração do ambiente de execução do crawler.

### Passo 1
Instale o [docker](https://docs.docker.com/install/) e o [docker-compose](https://docs.docker.com/compose/install/).

### Passo 2
Faça o build da imagem docker com as dependências do crawler
```
make build
```

Caso você não tenha o make instalado é possível executar o comando diretamente:

```
docker build -t crawler-ta-na-mesa scripts/	
```

### Passo 3
Execute o crawler para baixar os dados

```
make run ano=<ano_para_baixar>
```

Substitua <ano_para_baixar> com um ano de sua escolha para download.

É também possível executar o comando docker diretamente

```
docker run --rm -it -v `pwd`/data/:/code/scripts/data crawler-ta-na-mesa python3.6 fetch_all_data.py <ano_para_baixar> ./data
```

Substitua <ano_para_baixar> com um ano de sua escolha para download.

## Para realizar o processamento de dados - Serviço r-process

O docker irá facilitar a execução do processamento e limpeza de dados do TCE para o formato utilizado na aplicação Tá na Mesa!

### Passo 1

Será preciso configurar as variáveis de ambiente necessárias para o serviço executar:

a) Crie uma cópia do arquivo .env.sample no **diretório raiz desse repositório** e renomeie para `.env` (deve também estar no diretório raiz desse repositório)

b) Preencha as variáveis contidas no .env.sample também para o `.env`. Altere os valores conforme sua necessidade. Atente que se você está usando o banco local, o valor da variável POSTGRES_HOST deve ser *postgres*, que é o nome do serviço que será levantado pelo docker-compose.

### Passo 2

Do **diretório raiz desse repositório** execute o comando a seguir que irá levantar os serviços:

```
docker-compose up -d
```

### Passo 3
Uma vez baixados os dados para os anos de interesse. Execute o script de processamento:

Execute o comando auxiliar
```
make process-data anos=2018,2019,2020
```
Obs: o parâmetro anos pode conter um ou mais anos (estes separados por vírgula).

Ou se preferir execute o comando diretamente no docker
```
docker exec -it r-container sh -c "cd /app/code/processor && Rscript export_dados_bd.R 2018,2019,2020"
```

Os dados processados estarão disponíveis no diretório `data/bd`.

Para processar dados de empenhos é possível executar o comando:
Obs: Execute esse processamento após ter populado o banco de dados usando os passos descritos no README do diretório **feed**.

```
make process-data-empenhos
```

Os dados processados de empenhos estarão disponíveis no diretório `data/bd`.

Para processar dados de novidades é possível executar o comando:
Obs: Execute esse processamento após ter gerado todo o pré-processamento para os dados de licitações, contratos e empenhos (seguindo os passos anteriores).

```
make process-data-novidades
```

Os dados processados de novidades estarão disponíveis no diretório `data/bd`.

### Como executar outros scripts?

Para executar outros scripts criados usando R no Serviço r-process basta alterar o caminho para o arquivo no comando docker.

Exemplo:
```
docker exec -it r-container sh -c "cd /app/code/ideb && Rscript export_ideb.R"
```

Este comando irá executar o script de exportação dos dados do IDEB.

### Como adicionar novos pacotes?
Caso algum pacote novo tenha que ser adicionado ao r-container, basta adicionar o nome do pacote na seção de instalação de dependências do Dockerfile presente no diretório `code`. Existe um exemplo para o pacote here neste Dockerfile.

## Como levantar o banco de dados?
Para levantar o banco de dados siga os passos descritos no README do diretório **feed**. Lá serão apresentados os passos necessários para a utilização do serviço de configuração e alimentação do banco de dados. Atente-se para não repetir passos como o levantamento dos serviços usando o docker-compose.
