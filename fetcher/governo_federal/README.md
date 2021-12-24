## Fetcher do Governo Federal

Esse módulo é responsável por baixar os dados de licitções, empenhos e itens de empenho do Governo Federal.

Bases de dados:

- Licitações
- Empenhos
- Empenhos relacionados (ligação entre empenhos e licitações)
- Itens de empenho
- Histórico de itens de empenho

Esse fetcher reusa o código do [transparencia-gov-br](https://github.com/turicas/transparencia-gov-br) criado pelo  Turicas.

Para executar o fetcher no contexto do ta-de-pe execute:

```sh
./fetch_dados_federais.sh 2018-01-01 2022-01-01
```

Você pode passar qualquer data para o intervalo desde que esteja no formato: YYYY-MM-DD.

O log de execução pode ser visto em:

`fetcher/governo_federal/transparencia_gov/data/log`

Os arquivos .log são referentes a cada base de dados.

Para garantir que o submódulo do repositório do transparencia-gov-br esteja disponível, da raiz desse repositório execute:

```
git submodule update --init --recursive
```

O ta-de-pe-dados usa um fork do repositório do turicas diponível [aqui](https://github.com/analytics-ufcg/transparencia-gov-br).
