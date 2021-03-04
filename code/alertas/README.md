## Malha fina - Alertas

Este módulo é responsável por processar os alertas da Malha FIna da Transparência Brasil.

O arquivo `processa_alertas_data.R` possui funções para criar a lista de tipos de alerta bem como processar alertas como: curto intervalo de tempo entre a abertura da empresa e a data do primeiro contrato, fornecimento de produtos fora do ramo do fornecedor a partir de seus cnaes.

### Casos especiais

O arquivo `cnaes_desconsiderados_produtos.csv` contém a lista de cnaes que devem ser desconsiderados no cálculo dos produtos fora do ramo de fornecedor. Essa lista busca evitar casos de incoerência no cálculo de produtos incomuns para um conjunto de cnaes do fornecedor.

O arquivo deve ser preenchido obedecendo as colunas: `id_cnae` e `assunto`. Sendo a coluna `assunto` podendo conter os valores: `merenda`, `covid` ou `geral` (caso o cnae deva ser considerando independente da versão do filtro de licitações). O id do cnae deve obedecer o padrão CNAE 2.3 do IBGE com 7 dígitos.
