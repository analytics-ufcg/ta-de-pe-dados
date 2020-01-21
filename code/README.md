## Processamento para o Banco de Dados

Este diretório contém as funções e rotinas necessárias para executar o processamento para o banco de dados

Para realizar o processamento considerando dados dos núcleos de licitações e contratos execute o script ```export_dados_bd.R``` presente no diretório **processor**.

```
Rscript processor/export_dados_bd.R
```

Os dados serão salvos de forma tratada e pronta para inserção no banco de dados no diretório ```data/bd``` a partir da raiz desse repositório.

Obs: Este script assume que os dados foram baixados usando o módulo do crawler de dados (presente no diretório crawler na raiz desse repositório).

Foram processadas informações para as tabelas de:
- Licitações
- Contratos
- Itens das licitações
- Itens dos contratos
- Alterações dos contratos
- Estados Brasileiros
- Municípios do Rio Grande do Sul
