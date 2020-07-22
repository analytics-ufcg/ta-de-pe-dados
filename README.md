# Ta na mesa

Repositório de acesso a dados de licitações, empenhos e contratos do Tribunal de Contas do Estado do Rio Grande do Sul.

Este README é dividido em três partes principais.

- Explicação sobre o serviço que baixa os dados do TSE (**Crawler Tá na Mesa**)
- Explicação sobre o serviço que processa os dados do TSE para o formato usado no tá na mesa (**Processa dados Tá na Mesa**).
- Explicação sobre o serviço que gerencia o carregamento dos dados processados no banco de dados (**Feed Tá na Mesa**).

## Antes de tudo

Todos os serviços utilizados pelo Tá na Mesa utilizam docker para configuração do ambiente e execução do script.

Instale o [docker](https://docs.docker.com/install/) e o [docker-compose](https://docs.docker.com/compose/install/). Tenha certeza que você também tem o [Make](https://www.gnu.org/software/make/) instalado.

O processamento de dados do Tá na Mesa tem os seguintes passos:

1. Download dos dados brutos no TCE-RS
2. Processamento dos dados de licitações e contratos
3. Importação dos dados de licitações e contratos para o BD.
4. Importação dos dados de empenhos (vindos diretamento do TCE) para o BD.
5. Processamento dos dados de empenhos processados.
6. Importação dos dados de empenhos processados para o BD.
7. Processamento dos dados de novidades.
8. Importação dos dados de novidades para o BD.

Para realizar estes passos siga o tutorial:

## Crawler Tá na Mesa

A primeira etapa para o setup do repositório é baixar os dados brutos de licitações, contratos e empenhos disponibilizados pelo [TCE-RS](http://dados.tce.rs.gov.br/) na forma de dados abertos.

Para isto usaremos o **Crawler Tá na Mesa**

### Passo 1.1

Faça o build da imagem docker com as dependências do crawler

```shell
make crawler-build
```

Obs: todos comandos citados nesse README utilizam o make como facilitador para execução. Caso você queira executar os comandos docker diretamente confira o código correspondende a seu comando no arquivo `Makefile` na raiz desse repositório.

### Passo 1.2

Execute o **Crawler Tá na Mesa** para baixar os dados.

```shell
make crawler-run ano=<ano_para_baixar>
```

Substitua <ano_para_baixar> com um ano de sua escolha para download (2018, 2019 e 2020 foram os anos já testados para download).

## Serviços de processamento dos dados

Nesta etapa iremos levantar os demais serviços usados no processamento de dados para o Tá na Mesa.

### Passo 2.1

Será preciso configurar as variáveis de ambiente necessárias para os serviços executarem:

a) Crie uma cópia do arquivo .env.sample no **diretório raiz desse repositório** e renomeie para `.env` (deve também estar no diretório raiz desse repositório)

b) Preencha as variáveis contidas no .env.sample também para o `.env`. Altere os valores conforme sua necessidade. Atente que se você está usando o banco local, o valor da variável POSTGRES_HOST deve ser *postgres*, que é o nome do serviço que será levantado pelo docker-compose.

### Passo 2.2

Do **diretório raiz desse repositório** execute o comando a seguir que irá levantar os serviços:

```shell
docker-compose up -d
```

É possível verificar os serviços em execução:

```shell
docker ps
```

### Passo 2.3

Conforme explicado na seção anterior é preciso fazer o download dos dados para os anos de interesse usando o `Crawler Tá na Mesa`

Execute o script de processamento dos dados gerais vindos do TSE:

```shell
make process-data anos=2018,2019,2020
```

Obs: o parâmetro anos pode conter um ou mais anos (estes separados por vírgula).

Os dados processados estarão disponíveis no diretório `data/bd`.

### Passo 2.4

Importe os dados que foram processados (licitações e contratos) e os dados brutos de empenho no BD fazendo:

a) Crie as tabelas necessárias

```shell
make feed-create
```

b) Importe os dados para as tabelas

```shell
make feed-import-data
```

c) Import os dados de empenhos (vindos diretamento do TCE)

```shell
make feed-import-empenho-raw
```

Obs: Este comando pode demorar bastante devido ao carregamento dos Empenhos.

### Passo 2.5

Processe os dados de empenhos:

```shell
make process-data-empenhos
```

Os dados processados de empenhos estarão disponíveis no diretório `data/bd`.

Importe os dados de empenhos processados para o BD:

```shell
make feed-import-empenho
```

### Passo 2.6

Processe os dados de novidades:

```shell
make process-data-novidades
```

Os dados processados de empenhos estarão disponíveis no diretório `data/bd`.

Importe os dados de novidades para o BD:

```shell
make feed-import-novidade
```

Pronto! Todo o processamento de dados e carregamento para o banco de dados foi realizado.

## Como acessar o banco de dados

Uma vez que o serviços de preocessamento tiverem sido levantados (`docker-compose up -d`). O banco de dados também terá sido levantado.

Para acessar basta:

```shell
make feed-shell
```

## Outros comandos úteis

Para dropar as tabelas dos dados processados pelo Tá na Mesa:

```shell
make feed-clean-data
```

Para dropar as tabelas dos dados de empenhos baixados no TCE e upados para o banco de dados:

```shell
make feed-clean-empenho
```

Para executar o script de atualização dos dados (considera que os CSV's na pasta `bd` já foram processados):

```shell
docker exec -it feed python3.6 /feed/manage.py update-data
```

## Como executar outros scripts

Para executar outros scripts criados usando R no Serviço **Processa dados Tá na Mesa** basta alterar o caminho para o arquivo no comando docker.

Exemplo:

```shell
docker exec -it r-container sh -c "cd /app/code/ideb && Rscript export_ideb.R"
```

Este comando irá executar o script de exportação dos dados do IDEB.

## Como adicionar novos pacotes

Caso algum pacote novo tenha que ser adicionado ao r-container, basta adicionar o nome do pacote na seção de instalação de dependências do Dockerfile presente no diretório `code`. Existe um exemplo para o pacote here neste Dockerfile.


## Como executar a atualização dos dados usando um helper

Nesta seção iremos explorar como realizar a atualização dos dados usando o script de update: `update-data.sh`

Obs: O arquivo update-data.sh faz uso de um arquivo de variáveis de ambiente: `env.update`. Neste arquivo é possível alterar o local de escrita do arquivo de log de execução do update-data.sh.

Primeiro é preciso dar permissão de execução ao script:

```
chmod +x update-data.sh
```

É possível verificar quais os comandos possíveis de serem executados pelo helper fazendo:

```
./update.sh -help
```

### Para baixar e processar os dados pela primeira vez é possível executar

```
./update.sh -run-full-update
```

Este processo pode demorar bastante dependendo da sua conexão e da capacidade de processamento da sua máquina. Seu banco de dados local já estará pronto para uso.

### Para atualizar o Banco de dados Remoto com os dados já processados

Será preciso configurar as variáveis de ambiente necessárias para o serviço executar:

a) Crie uma cópia do arquivo .env.sample no **diretório raiz desse repositório** e renomeie para `.env.prod` (deve também estar no diretório raiz desse repositório)

b) Preencha as variáveis contidas no .env.sample também para o `.env.prod`. Altere os valores para o banco de dados remoto que você deseja atualizar.

```
./update.sh -run-update-db-remote
```

Seus dados serão atualizados remotamente.

### Configure a atualização periodicamente

Para configurar a atualização periodicamente é possível adicionar no crontab o comando correspondente da atualização.

Abra seu crontab para edição:
```
crontab -e
```

Adicione a seguinte linha (modifique o caminho de acordo com sua máquina):
```
0 7 2 * * cd <caminho_para_repositorio>; /bin/bash <caminho_para_repositorio>/update-data.sh -run-full-update; /bin/bash <caminho_para_repositorio>/update-data.sh -run-update-db-remote
```

No dia 2 de cada mês o script a atualização irá se iniciar as 7 horas da manhã.
