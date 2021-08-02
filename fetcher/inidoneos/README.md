## Fetcher Inidôneos

Este módulo é responsável por baixar os dados de Empresas inidôneas segundo o Portal de Transparência do Governo Federal.


Dados baixados:
- CEIS (Cadastro Nacional de Empresas Inidôneas e Suspensas) 
- CNEP (Cadastro Nacional das Empresas Punidas)

Como usar:

```
Rscript export_cadastro_inidoneos.R
```

Os dados serão salvos em csvs: `data/ceis.csv` e `data/cnep.csv`
