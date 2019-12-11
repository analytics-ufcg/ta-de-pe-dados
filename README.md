# Ta na mesa

Repositório de acesso a dados de licitações, empenhos e contratos do Tribunal de Contas do Estado do Rio Grande do Sul.

## Como executar

Para baixar dados das licitações:
```sh
$ python3.6 scripts/fetch_licitacoes.py <ano>
```

Para baixar dados dos empenhos:
```sh
$ python3.6 scripts/fetch_empenhos.py <ano>
```

Para baixar dados dos contratos:
```sh
$ python3.6 scripts/fetch_contratos.py <ano>
```

## Para baixar todos os dados usando docker

Instale o [docker](https://docs.docker.com/install/) e o [docker-compose](https://docs.docker.com/compose/install/).

Execute o serviço que baixa todos os dados para os anos de 2017, 2018 e 2019
```
docker-compose up
```
