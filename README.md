# *Tá de Pé?*

O **Tá de Pé?** é um sistema desenvolvido através da parceria entre a **Transparência Brasil** e o **Laboratório Analytics**, da Universidade Federal de Campina Grande-PB, com finalidade de permitir o acompanhamento de licitações e de contratos públicos.

# Camada de Dados

Este repositório contém a camada de dados do *Tá de Pé?*. Esta camada, ilustrada na imagem abaixo, fornece meios para extração, processamento, e armazenamento de dados do TCE de dois estados brasileiros, Rio Grande do Sul e Pernambuco, da Receita Federal e das compras realizadas pelo Governo Federal.

A Camada de Dados possui três componentes principais:

* **Fetcher**: responsável por buscar os dados de suas fontes. Note que temos um fetcher para cada fonte de dados;
* **Processor**: responsável por processar os dados para o formato usado no *Tá de Pé?* e encontrar alertas nos dados;
* **Feed**: responsável por carregar os dados para o banco de dados *Tá de Pé?*.

**DICA:** Caso você precise apenas configurar um ambiente de desenvolvimento e começar a contribuir de imediato as etapas de buscar dados de fontes (fetcher) e processar dados (processor) podem ser ignoradas, desde que você tenha acesso aos arquivos CSVs já processados e disponíveis no diretório `data/bd`.

Para mais detalhes, veja nossa [wiki](https://github.com/analytics-ufcg/ta-de-pe-dados/wiki).

# Setup

Todos os serviços utilizados pelo *Tá de Pé?* utilizam docker para configuração do ambiente e execução do script.

Instale o [docker](https://docs.docker.com/install/) e o [docker-compose](https://docs.docker.com/compose/install/). Tenha certeza que você também tem o [Make](https://www.gnu.org/software/make/) instalado.

Obs: todos comandos citados nesse README utilizam o make como facilitador para execução. Caso você queira executar os comandos docker diretamente confira o código correspondende a seu comando no arquivo `Makefile` na raiz desse repositório.

# Tutorial

Mais detalhadamente, cada componente da camada de dados do *Tá de Pé?* realiza as seguintes tarefas:

0. [Configuração dos Serviços Tá de pé dados](#0)
1. [Configuração dos Bancos de dados Locais](#1)
   - 1.1 [Configuração do Banco de dados local da Receita Federal](#11)
   - 1.2 [Configuração do Banco de dados local do Tome Conta (TCE-PE)](#12)
2. [Fetcher](#2)
   - 2.1 [Download dos dados brutos do TCE-RS](#21)
   - 2.2 [Download dos dados brutos do TCE-PE](#22)
   - 2.3 [Download dos dados brutos do Governo Federal](#23)
3. [Processor](#3)
   - 3.1 [Processamento dos dados de licitações e contratos](#31)
   - 3.2 [Processamento dos dados de fornecedores](#32)
   - 3.3 [Processamento dos dados da Receita Federal](#33)
   - 3.4 [Processamento dos dados de empenhos processados](#34)
   - 3.5 [Processamento dos dados de novidades](#35)
   - 3.6 [Processamento dos dados de alertas](#36)
4. [Feed](#4)
   - 4.1 [Importação dos dados de licitações e contratos (processados), e empenhos (brutos) para o BD](#41)
   - 4.2 [Importação dos dados de empenhos processados para o BD](#42)
   - 4.3 [Importação dos dados de novidades para o BD](#43)
   - 4.4 [Importação dos dados de alertas para o BD](#44)

Para realizar estas tarefas, siga o tutorial:

## 0. Configuração dos Serviços Tá de pé dados <a name="0"></a>

Precisamos levantar os serviços usados no processamento de dados. Para isso, é preciso configurar as variáveis de ambiente necessárias para os serviços executarem:

a) Crie uma cópia do arquivo .env.sample no **diretório raiz desse repositório** e renomeie para `.env` (deve também estar no diretório raiz desse repositório)

b) Preencha as variáveis contidas no .env.sample também para o `.env`. Altere os valores conforme sua necessidade. Atente que se você está usando o banco local, o valor da variável `POSTGRES_HOST` deve ser *postgres*, que é o nome do serviço que será levantado pelo docker-compose. Contate a equipe em caso de dúvida.

c) Atualize a dependência do github submodule para o fetcher do Governo Federal:

```shell
git submodule update --init --recursive
```

Acesse o [README](fetcher/governo_federal/README.md) para mais informações.

d) Do **diretório raiz desse repositório** execute o comando a seguir que irá levantar os serviços:

Você pode opcionalmente realizar o build das imagens:

```shell
docker-compose build
```

Caso o seguite erro apareça:
```
error checking context: 'can't stat '<path>/ta-de-pe-dados/data/postgres_data''.
ERROR: Service 'rbase' failed to build : Build failed
```

execute o seguinte comando para alterar a permissão de acesso ao diretório do postgres_data:

```
sudo chown -R <seu-user>:<seu-user> data/
```

```shell
docker-compose up -d
```

d) É possível verificar os serviços em execução:

```shell
docker ps
```

## 1. Configuração dos Bancos de dados Locais <a name="1"></a>

Execute este passo apenas se você quer repetir todo o processo de obtenção/processamento dos dados.
Esses processos podem demorar bastante.

### Passo 1.1 - Configuração do Banco de dados local da Receita Federal <a name="11"></a>

[Link](https://github.com/JoaquimCMH/receita-cnpj-dados) para as instruções de configuração do banco de dados do Cadastro Nacional da Pessoa Jurídica (CNPJ) oriundos da Receita Federal.

### Passo 1.2 - Configuração do Banco de dados local do Tome Conta (TCE-PE) <a name="12"></a>

[Link](https://github.com/JoaquimCMH/tomeconta-tce-pe-dados) para as instruções de configuração do banco de dados do Tribunal de Contas do estado de Pernambuco.


## 2. Fetcher <a name="2"></a>

A primeira etapa consiste em baixar os dados brutos, disponíveis na forma de dados abertos, de suas fontes. Assim, baixamos os dados de licitações, contratos e empenhos disponibilizados pelo [TCE-RS](http://dados.tce.rs.gov.br/) e pelo [TCE-PE](https://www.tce.pe.gov.br/internet/index.php/dados-abertos/bases-de-dados-completas), e os dados referentes à informações dos fornecedores disponíveis no Banco da Receita Federal.


### Passo 2.1 <a name="21"></a>

Execute o seguinte comando para baixar os dados do TCE-RS.

```shell
make fetch-data-rs ano=<ano_para_baixar>
```

Substitua <ano_para_baixar> com um ano de sua escolha para download (2018, 2019 e 2020 foram os anos já testados para download).

### Passo 2.2 <a name="22"></a>

Execute o seguinte comando para baixar os dados do TCE-PE.

```shell
make fetch-data-pe ano_inicial=<ano> ano_final=<ano>
```

### Passo 2.2 <a name="22"></a>

Execute o seguinte comando para baixar os dados do Governo Federal

TODO - ainda não implementado

## 3. Processor <a name="3"></a>

Esta etapa consiste em processar os dados para o formato que utilizamos e encontrar alertas.

### Passo 3.1 <a name="31"></a>

Obs: É preciso ter feito o download dos dados para os anos de interesse, conforme explicado na seção *Fetcher*.

Atenção! Caso você tenha interesse em processar os dados federais é necessário carregar
os dados de empenhos e itens de empenho federais no banco de processamento para que
o ta de pe dados possa realizar a limpeza e o filtro nesses dados:
para isto execute:

```
make feed-create-empenho-raw-gov-federal
make feed-import-empenho-raw-gov-federal
```

Execute o script de processamento dos dados gerais:

```shell
make process-data anos=2018,2019,2020,2021 filtro=merenda estados=RS,PE,BR
```

Obs: o parâmetro anos pode conter um ou mais anos (estes separados por vírgula). O parâmetro filtro pode ser 'merenda' ou 'covid'. O parâmetro estados pode conter um
ou mais estados.

Os dados processados estarão disponíveis no diretório `data/bd`.

#### Passo 3.2 <a name="32"></a>

Para processar as informações de fornecedores (como data do primeiro contrato e total de contratos), execute:

```shell
make process-data-fornecedores anos=2018,2019,2020,2021
```

#### Passo 3.3 <a name="33"></a>

Para processar as informações da Receita Federal para os fornecedores, execute:

```shell
make fetch-process-receita
```

Obs: é necessário que as variáveis de acesso ao BD estejam definidas no .env na raiz do repositório.
As variáveis necessárias para conexão são:
```shell
RECEITA_HOST
RECEITA_USER
RECEITA_DB
RECEITA_PASSWORD
RECEITA_PORT
```
Entre em contato com a equipe de desenvolvimento para ter acesso as variáveis do BD disponível para acesso.

#### Passo 3.4 <a name="34"></a>

Obs: É preciso realizar o passo 4.1 antes deste.

Processe os dados de empenhos:

```shell
make process-data-empenhos
```

Os dados processados de empenhos estarão disponíveis no diretório `data/bd`.

### Passo 3.5 <a name="35"></a>

Processe os dados de novidades:

```shell
make process-data-novidades
```

Os dados processados de novidades estarão disponíveis no diretório `data/bd`.

### Passo 3.6 <a name="36"></a>

Processe os dados de alertas referentes a produtos atípicos:

```shell
make process-data-itens-similares
```

Processe os dados de alertas referentes a fornecedores contratados logo após a abertura da empresa:

```shell
make process-data-alertas anos=2018,2019,2020,2021 filtro=merenda estados=RS,PE,BR
```

Os dados processados de alertas estarão disponíveis no diretório `data/bd`.

## 4. Feed <a name="4"></a>

### Passo 4.1 <a name="41"></a>

Importe os dados que foram processados (licitações e contratos) e os dados brutos de empenhos no BD fazendo:

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

### Passo 4.2 <a name="42"></a>

Importe os dados de empenhos processados para o BD:

```shell
make feed-import-empenho
```

### Passo 4.3 <a name="43"></a>

Importe os dados de novidades para o BD:

```shell
make feed-import-novidade
```

### Passo 4.4 <a name="44"></a>

Importe para o BD os dados de alertas sobre produtos atípicos:

```shell
make feed-import-itens-similares-data
```

Importe para o BD os dados de alertas sobre fornecedores contratados logo após a abertura da empresa:

```shell
make feed-import-alerta
```

Pronto! Todo o processamento de dados e carregamento para o banco de dados foi realizado.

## Acessando o banco de dados

Uma vez que o serviços de processamento tiverem sido levantados (`docker-compose up -d`), o banco de dados também terá sido levantado.

Para acessar o banco, execute:

```shell
make feed-shell
```

## Outros comandos úteis

Para dropar as tabelas dos dados processados pelo *Tá de Pé?*, execute:

```shell
make feed-clean-data
```

Para dropar as tabelas dos dados de empenhos brutos importados para o banco de dados, execute:

```shell
make feed-clean-empenho
```

Para executar o script de atualização dos dados (considera que os CSV's na pasta `bd` já foram processados), execute:

```shell
docker exec -it feed python3.6 /feed/manage.py update-data
```

## Executando outros scripts

Para executar outros scripts criados usando R no Serviço **Processor**, basta alterar o caminho para o arquivo no comando docker.

Exemplo:

```shell
docker exec -it r-container sh -c "cd /app/code/ideb && Rscript export_ideb.R"
```

Este comando irá executar o script de exportação dos dados do IDEB.

## Adicionando novos pacotes

Caso algum pacote novo tenha que ser adicionado ao r-container, basta adicionar o nome do pacote na seção de instalação de dependências do Dockerfile presente no diretório `code`. Existe um exemplo para o pacote here neste Dockerfile.

## Atualizando os dados usando um helper

Nesta seção iremos explorar como realizar a atualização dos dados usando o script de update: `update-data.sh`

Obs: O arquivo update-data.sh faz uso de um arquivo de variáveis de ambiente: `.env`. Neste arquivo é possível alterar o local de escrita do arquivo de log de execução do update-data.sh.

Primeiro é preciso dar permissão de execução ao script:

```
chmod +x update-data.sh
```

É possível verificar quais os comandos possíveis de serem executados pelo helper:

```
./update-data.sh -help
```

### Para baixar, processar, e importar os dados com um único comando, execute:

```
./update-data.sh --tipo merenda --contexto development --ano-inicio 2020 --ano-fim 2021 --estados RS,PE,BR
```

Este processo pode demorar bastante dependendo da sua conexão e da capacidade de processamento da sua máquina. Seu banco de dados local já estará pronto para uso.

### Configure a atualização periodicamente

Para configurar a atualização periodicamente é possível adicionar no crontab o comando correspondente da atualização.

Abra seu crontab para edição:
```
crontab -e
```

Adicione a seguinte linha (modifique o caminho de acordo com sua máquina):
```
0 7 2 * * cd <caminho_para_repositorio>; /bin/bash <caminho_para_repositorio>/update-data.sh --tipo merenda --contexto development --ano-inicio 2019 --ano-fim 2020
```

No dia 2 de cada mês o script de atualização irá se iniciar às 7 horas da manhã.

### Azure

Este repositório tem um módulo dedicado a configurar a conexão e gerenciar a VM no Azure onde o ta-de-pe-dados pode estar executando em produção.

Para mais detalhes acesse [aqui](azure/README.md).