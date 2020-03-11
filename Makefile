ano=2019

.DEFAULT_GOAL : help
help:
	@echo "Ajuda do Serviço de dados do Tá na Mesa"
	@echo "Este arquivo irá ajudar a baixar e processar os dados usados no Tá na Mesa"	
	@echo "Você só precisa executar os comandos fazendo 'make <command>'"
	@echo "    "	
	@echo "    help - Mostra esta mensagem de ajuda"
	@echo "    "	
	@echo "    crawler-build - Realiza o build da imagem com as dependência do crawler do tá na mesa"
	@echo "    "	
	@echo "    crawler-run ano=<ano> - Executa a cli do crawler para o ano passado como parâmetro. (2019 é o default)"
	@echo "    "	
	@echo "    process-data anos=2017,2018,2019,2020 - Executa o módulo de processamento de dados brutos para o formato usado na aplicação."
	@echo "    Assume um ou mais anos separados por vírgula. Assume que os dados foram baixados."
	@echo "    "	
	@echo "    process-data-empenhos - Executa o processamento de dados de empenhos.
	@echo "    "	
	@echo "    process-data-novidades - Executa o processamento de dados de novidades.
	@echo "    "	
	@echo "    feed-create - Cria as tabelas usadas no Tá na Mesa no Banco de Dados.
	@echo "    "	
	@echo "    feed-import-data - Importa dados dos CSV's (licitações e contratos) para o Banco de dados 
	@echo "    "	
	@echo "    feed-import-empenho - Importa dados do CSV processado de empenhos para o Banco de dados 
	@echo "    "
	@echo "    feed-import-novidade - Importa dados do CSV processado de novidades para o Banco de dados 
	@echo "    "
	@echo "    feed-shell - Abre terminal psql com o banco cadastrado nas variáveis de ambiente
	@echo "    "
.PHONY: help
crawler-build:
	docker build -t crawler-ta-na-mesa scripts/	
.PHONY: build
crawler-run:
	docker run --rm -it -v `pwd`/data/:/code/scripts/data/ crawler-ta-na-mesa python3.6 fetch_orgaos.py ./data
	docker run --rm -it -v `pwd`/data/:/code/scripts/data/ crawler-ta-na-mesa python3.6 fetch_all_data.py $(ano) ./data
.PHONY: run
process-data:	
	docker exec -it r-container sh -c "cd /app/code/processor && Rscript export_dados_bd.R $(anos)"
.PHONY: process-data
process-data-empenhos:	
	docker exec -it r-container sh -c "cd /app/code/processor && Rscript export_empenhos_bd.R"	
.PHONY: process-data-empenhos
process-data-novidades:		
	docker exec -it r-container sh -c "cd /app/code/processor && Rscript export_novidades_bd.R"
.PHONY: process-data-novidades 
feed-create:	
	docker exec -it feed python3.6 /feed/manage.py create
.PHONY: feed-create
feed-import-data:	
	docker exec -it feed python3.6 /feed/manage.py import-data
.PHONY: feed-import-data
feed-import-empenho:	
	docker exec -it feed python3.6 /feed/manage.py import-empenho
.PHONY: feed-import-empenho
feed-import-novidade:	
	docker exec -it feed python3.6 /feed/manage.py import-novidade
.PHONY: feed-import-novidade
feed-shell:	
	docker exec -it feed python3.6 /feed/manage.py shell
.PHONY: feed-shell