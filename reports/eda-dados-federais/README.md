## Exploração sobre os dados de compras do Governo Federal

### Bases de dados

As bases de dados usadas foram disponibilizadas pelo Brasil.IO no [Google Drive](https://drive.google.com/drive/folders/1-XL0Je--FjdfeP5LE3ljd4hB5LeqMW4G).

Baixe os arquivos: `despesa_empenho.csv.gz` e `despesa_item_empenho.csv.gz` para o diretório `data` presente no mesmo diretório deste README.

### Diretórios/módulos

- `data/` - armazena os dados brutos das bases de dados que devem ser baixadas conforme explicado na seção anterior.
- `load/` - contém os scripts sql reponsáveis por carregar os dados baixados na diretório `data/` para o banco de dados
- `bd/` : diretório com o volume docker do banco postgres com os dados federais. Ou seja, é onde ficam os dados persistentes das tabelas do BD de dados federais.
- `metabase-data` :  diretório com o volume docker par armazenar os aquivos persistentes do metabase. O [Metabase](https://www.metabase.com/) é uma ferramenta exploratória para bancos de dados.

### Serviços

Este diretório oferece um docker-compose.yml que orquestra 2 serviços.

1. db-dados-federais: banco de dados postgres para carregamento e armazenamento dos dados federais a serem analisados.
2. metabase: ferramenta para análise exploratória do banco de dados.

Para levantar os serviços:

```
docker-compose up
```

Execute:
1. `make create-schema` para criar as tabelas.
2. `make import-data` para importar os dados.

Acesse http://localhost:3009/ para configurar o Metabase.

Você deve preencher o formulário que ele fornece.
Nas credenciais do banco lembre-se que:
o Host/servidor é o `postgres-dados-federais`, o user é `postgres` e a senha provisória é `secret`.

TODO: configurar arquivo para que a etapa de preencher o formulário no metabase não seja necessária.

Agora é só explorar o Metabase!
