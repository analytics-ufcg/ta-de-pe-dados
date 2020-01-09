# Ta na mesa

Repositório de acesso a dados de licitações, empenhos e contratos do Tribunal de Contas do Estado do Rio Grande do Sul.

## Como executar

Para baixar dados das licitações:
```sh
$ python3.6 fetch_licitacoes.py <ano>
```

Para baixar dados dos empenhos:
```sh
$ python3.6 fetch_empenhos.py <ano>
```

Para baixar dados dos contratos:
```sh
$ python3.6 fetch_contratos.py <ano>
```

## Para baixar os dados usando Docker

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

É também possível executar o comando diretamente

```
	docker run --rm -it -v `pwd`/data/:/code/scripts/data crawler-ta-na-mesa python3.6 fetch_all_data.py <ano_para_baixar> ./data
```

Substitua <ano_para_baixar> com um ano de sua escolha para download.
