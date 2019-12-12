ano=2019

.DEFAULT_GOAL : help
help:
	@echo "Ajuda do Crawler de dados do Tá na Mesa"
	@echo "Este arquivo irá ajudar a baixar os dados usados no Tá na Mesa"	
	@echo "Você só precisa executar os comandos fazendo 'make <command>'"
	@echo "    "	
	@echo "    help - Mostra esta mensagem de ajuda"
	@echo "    "	
	@echo "    build - Realiza o build da imagem com as dependência do crawler"
	@echo "    "	
	@echo "    run ano=<ano> - Executa a cli do crawler para o ano passado como parâmetro. (2019 é o default)"
	@echo "    "	
.PHONY: help
build:
	docker build -t crawler-ta-na-mesa scripts/	
.PHONY: build
run:	
	docker run --rm -it -v `pwd`/data/:/code/scripts/data/ crawler-ta-na-mesa python3.6 fetch_all_data.py $(ano) ./data
.PHONY: run
