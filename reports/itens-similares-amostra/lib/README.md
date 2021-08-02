## Como gerar os dados de itens similares

Este README irá explicar como recuperar dados de itens similares usando a API do Tá na Mesa!

### Conexão com a API


#### Configuração da aplicação

Você irá precisar:

1. Ter uma versão do Banco de dados executando. Leia o [README](https://github.com/analytics-ufcg/ta-na-mesa-dados/blob/master/README.md) principal deste repositório.
2. Ter a API executando. Leia o [README](https://github.com/analytics-ufcg/ta-na-mesa/blob/master/README.md) do repositório da aplicação.

Após ter a aplicação localmente executando. Lembre de estar na branch report-dados-itens-similares.

#### Configuração da comunicação entre R e aplicação

Se você usa o Rstudio localmente a variável da URL de conexão com a api será:

```
"http://localhost:5000/api/itensContrato/similares"
```

Se você usa o R dentro de um container docker então será preciso:
1. Adicionar o seu container na mesma network do container da API:

```
docker network connect ta_na_mesa_network <id_do_seu_container_R>
```

2. Sua variável da URL será (Configura o nome do container docker que está servindo a API):

```
"http://ta-de-pe_backend_1:5000/api/itensContrato/similares"
```

#### Executando processamento

Agora, basta executar o processamento.
De dentro do diretório `reports/itens-similares/lib` execute:

```
Rscript export_itens_similares.R -u sua_url_da_api -n 1000
```
sua_url_da_api deve ser trocada pela URL correspondente ao seu desenvolvimento como supracitado. Ou seja, pode ser "http://localhost:5000/api/itensContrato/similares" ou "http://ta-de-pe_backend_1:5000/api/itensContrato/similares"


O valor de n igual a 1000 (pode ser modificado) indica o número de consultas que serão realizadas à API. Cada consulta é a pesquisa de um item com o retorno de seus itens similares.

O resultado do processamento pode ser conferido em: `reports/itens-similares-amostra/data/itens_similares.csv`
