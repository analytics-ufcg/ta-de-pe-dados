## Serviço de criação do banco de dados para licitações e empenhos

Motivado pelo tamanho dos arquivos de empenhos do processo de execução orçamentária do Rio Grande do Sul, este serviço busca configurar e disponibilizar um banco de dados com as informações de empenhos e das licitações associadas a estes empenhos.

Para levantar este serviço siga os passos:

### Passo 1
Instale o [docker](https://docs.docker.com/install/) e o [docker-compose](https://docs.docker.com/compose/install/).

### Passo 2

Será preciso configurar as variáveis de ambiente necessárias para o serviço executar:

a) Crie uma cópia do arquivo .env.sample no **diretório raiz desse repositório** e renomeie para `.env` (deve também estar no diretório raiz desse repositório)

b) Preencha as variáveis contidas no .env.sample também para o `.env`. Altere os valores conforme sua necessidade. Atente que se você está usando o banco local, o valor da variável POSTGRES_HOST deve ser *postgres*, que é o nome do serviço que será levantado pelo docker-compose.

### Passo 3

Caso não tenha feito ainda, partindo do **diretório raiz desse repositório** execute o comando a seguir que irá levantar os serviços feed, postgres e rbase

```
docker-compose up -d
```

feed: é o serviço que irá criar as tabelas e popular o banco de dados.
postgres: é o serviço com o banco de dados.
rbase: é o serviço de processamento dos dados usando R.

### Passo 4

Foi criada uma cli para facilitar a configuração do BD.

Execute os passos na ordem:

a) Crie as tabelas
```
docker exec -it feed python3.6 /feed/manage.py create
```

b) Importe os dados
```
docker exec -it feed python3.6 /feed/manage.py import-data
```

Pronto! Agora o banco de dados para verificar o resultado dessas operações.

### **Como acessar o banco de dados**

**1. (jeito mais simples) Para acessar o banco de dados (local ou remoto)**

Execute o comando disponível pela cli:

```
docker exec -it feed python3.6 /feed/manage.py shell
```

**2. (jeito mais complicado) Para acessar o banco de dados localmente execute:**

```
docker exec -it postgres-ta-na-mesa psql -h localhost -d <POSTGRES_DB> -U <POSTGRES_USER>
```

As credenciais (<POSTGRES_DB> e <POSTGRES_USER>) devem ser preenchidas conforme você especificou no arquivo .env.

A senha (preenchida no .env) será pedida ao executar este comando.

Obs: Se você tem o psql instalado em sua máquina local, também é possível acessar o banco de dados diretamente usando a porta 5433 da sua máquina local. (psql -h localhost -d <POSTGRES_DB> -U <POSTGRES_USER> -P 5433)

### Comandos úteis

Obs:
Para limpar o banco de dados execute:
```
docker exec -it feed python3.6 /feed/manage.py clean-data
```

Para atualizar o banco de dados execute:
```
docker exec -it feed python3.6 /feed/manage.py update-data
```

