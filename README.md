# Ta na mesa

Repositório de acesso a dados de licitações, empenhos e contratos do Tribunal de Contas do Estado do Rio Grande do Sul.

Este README é dividido em três partes principais. 
 - Explicação sobre o serviço que baixa os dados do TSE (**Crawler Tá na Mesa**)
 - Explicação sobre o serviço que processa os dados do TSE para o formato usado no tá na mesa (**Processa dados Tá na Mesa**).
 - Explicação sobre o serviço que gerencia o carregamento dos dados processados no banco de dados (**Feed Tá na Mesa**).

## Antes de tudo...

Todos os serviços utilizados pelo Tá na Mesa utilizam docker para configuração do ambiente e execução do script. 

Instale o [docker](https://docs.docker.com/install/) e o [docker-compose](https://docs.docker.com/compose/install/).

## Crawler Tá na Mesa

A primeira etapa para o setup do repositório é baixar os dados brutos de licitações, contratos e empenhos disponibilizados pelo [TCE-RS](http://dados.tce.rs.gov.br/) na forma de dados abertos.

Para isto usaremos o **Crawler Tá na Mesa**

### Passo 1
Faça o build da imagem docker com as dependências do crawler

```
make build-crawler
```

Obs: todos comandos citados nesse README utilizam o make como facilitador para execução. Caso você queira executar os comandos docker diretamente confira o código correspondende a seu comando no arquivo `Makefile` na raiz desse repositório.


### Passo 2
Execute o **Crawler Tá na Mesa** para baixar os dados.

```
make run-crawler ano=<ano_para_baixar>
```

Substitua <ano_para_baixar> com um ano de sua escolha para download (2018, 2019 e 2020 foram os anos já testados para download).

## Serviços de processamento dos dados

Nesta etapa iremos levantar os demais serviços usados no processamento de dados para o Tá na Mesa.

### Passo 1

Será preciso configurar as variáveis de ambiente necessárias para os serviços executarem:

a) Crie uma cópia do arquivo .env.sample no **diretório raiz desse repositório** e renomeie para `.env` (deve também estar no diretório raiz desse repositório)

b) Preencha as variáveis contidas no .env.sample também para o `.env`. Altere os valores conforme sua necessidade. Atente que se você está usando o banco local, o valor da variável POSTGRES_HOST deve ser *postgres*, que é o nome do serviço que será levantado pelo docker-compose.

### Passo 2

Do **diretório raiz desse repositório** execute o comando a seguir que irá levantar os serviços:

```
docker-compose up -d
```

É possível verificar os serviços em execução:

```
docker ps
```

### Passo 3
Conforme explicado na seção anterior é preciso fazer o download dos dados para os anos de interesse usando o `Crawler Tá na Mesa`

Execute o script de processamento dos dados gerais vindos do TSE:

```
make process-data anos=2018,2019,2020
```

Obs: o parâmetro anos pode conter um ou mais anos (estes separados por vírgula).

Os dados processados estarão disponíveis no diretório `data/bd`.

### Passo 4

Importe os dados que foram processados (licitações e contratos) e os dados brutos de empenho no BD fazendo:

a) Crie as tabelas necessárias

```
make feed-create
```

b) Importe os dados para as tabelas

```
make feed-import-data
```
Obs: Este comando pode demorar bastante devido ao carregamento dos Empenhos.

### Passo 5

Processe os dados de empenhos:

```
make process-data-empenhos
```
Os dados processados de empenhos estarão disponíveis no diretório `data/bd`.

Importe os dados de empenhos processados para o BD:

```
make feed-import-empenho
```

### Passo 6

Processe os dados de novidades:

```
make process-data-novidades
```
Os dados processados de empenhos estarão disponíveis no diretório `data/bd`.

Importe os dados de novidades para o BD:

```
make feed-import-novidade
```

Pronto! Todo o processamento de dados e carregamento para o banco de dados foi realizado.

## Como acessar o banco de dados?

Uma vez que o serviços de preocessamento tiverem sido levantados (`docker-compose up -d`). O banco de dados também terá sido levantado.

Para acessar basta:

```
make feed-shell
```

## Outros comandos úteis

TODO:


## Como executar outros scripts?

Para executar outros scripts criados usando R no Serviço r-process basta alterar o caminho para o arquivo no comando docker.

Exemplo:
```
docker exec -it r-container sh -c "cd /app/code/ideb && Rscript export_ideb.R"
```

Este comando irá executar o script de exportação dos dados do IDEB.

## Como adicionar novos pacotes?
Caso algum pacote novo tenha que ser adicionado ao r-container, basta adicionar o nome do pacote na seção de instalação de dependências do Dockerfile presente no diretório `code`. Existe um exemplo para o pacote here neste Dockerfile.
