## Malha fina - Alertas

Este módulo é responsável por processar os alertas da Malha FIna da Transparência Brasil.

O arquivo `export_alertas_bd.R` concentra o processo de:
1. Execução das funções que calculam cada alerta
2. Agregação dos alertas gerados em um único dataframe
3. Exportação desse dataframe como csv em: `data/bd/alerta.csv` (lista dos alertas gerados) e `data/bd/tipo_alerta.csv` com informações sobre os tipos de alertas gerados.

O diretório `functions/` contém os scripts em R com as funções definidas para calcular um alerta. Preferencialmente cada script possuirá uma função que calcula e retorna um dataframe com a alerta no formato correto. Neste script também pode existir funções auxiliares para execução do cálculo do alerta.

Caso existem funções auxiliares que são usadas por mais de um processador de alerta, então o mesmo estará localizado no diretório `functions/helpers/`.

O diretório `data/` contém os csv's usados durante o cálculo dos alertas.
### Exemplo de csv de configuração usado no cálculo do alerta

O arquivo `data/cnaes_desconsiderados_produtos.csv` contém a lista de cnaes que devem ser desconsiderados no cálculo dos produtos fora do ramo de fornecedor. Essa lista busca evitar casos de incoerência no cálculo de produtos incomuns para um conjunto de cnaes do fornecedor.

O arquivo deve ser preenchido obedecendo as colunas: `id_cnae` e `assunto`. Sendo a coluna `assunto` podendo conter os valores: `merenda`, `covid` ou `geral` (caso o cnae deva ser considerando independente da versão do filtro de licitações). O id do cnae deve obedecer o padrão CNAE 2.3 do IBGE com 7 dígitos.

### Formato do retorno para os alertas

Cada função que calcula/processa um alerta deve retornar um dataframe com as seguintes colunas:

`nr_documento`: cpf ou cnpj do fornecedor ligado ao alerta
`id_contrato`: id do contrato identificado para o alerta. Deve ser NA se nenhum contrato monitorado está associado ao alerta.
`id_tipo`: id do tipo do alerta
`info`: Texto com informação extra sobre o alerta.

## Lista de alertas atuais

1. Contratado logo após a abertura: Fornecedores que foram contratados pouco depois da data de abertura da empresa na Receita Federal
2. Produtos atípicos: Fornecedores que foram contratados para o abastecimento de produtos que são atípicos considerando o CNAE desses fornecedores.
3. Contratado inidôneo: Fornecedores que foram contratados enquanto estavam com sanções vigentes no CEIS ou no CNEP.
4. Faturamento alto: Fornecedores com valor contratado acima do limite de faturamento definido para seu porte cadastrado na Receita Federal.

## Como gerar um novo alerta?

#### Passo 1:
Crie um novo script R em `functions`

#### Passo 2:
Adiciona uma função nesse novo script e certifique-se que a função possui documentação e um retorno de acordo com o formato do alerta (colunas obrigatórias: nr_documento, id_contrato, id_tipo, info). O conteúdo dessa função é o que define o alerta com os critérios desejados. Você pode nesse mesmo script R definir outras funções auxiliares para serem chamadas pela função principal que processa o alerta.

#### Passo 3:
Adicione no arquivo `functions/processa_tipos_alerta.R` um novo identificador e um novo nome para o tipo de alerta que está sendo gerado.

#### Passo 4:
Modifique o `export_alertas_bd.R` para importar o script criado no passo 2 e chamara a função principal criada também no passo 2. Certifique-se também que o novo alerta foi adicionado ao agregador definido pelo comando `bind_rows`. O alerta processado no passo 2 deve possuir as mesmas colunas de outros alertas produzidos por outras funções do módulo `functions`.

