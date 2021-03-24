ano=2019

.DEFAULT_GOAL : help
help:
	@echo "\nTá na mesa - Serviço de dados"
	@echo "Este arquivo ajuda no download e processamento dos dados usados no Tá na Mesa\n"
	@echo "COMO USAR:\n\t'make <comando>'\n"
	@echo "COMANDOS:"
	@echo "\thelp \t\t\t\tMostra esta mensagem de ajuda"
	@echo "\tbuild-fetcher-data-rs \t\t\tRealiza o build da imagem com as dependência do fetcher do tá na mesa"
	@echo "\tfetch-data-rs ano=<ano> \t\tExecuta a cli do fetcher para o ano passado como parâmetro. (2019 é o default)"
	@echo "\tfetch-data-pe \t\t\tRecupera dados do TCE-PE."
	@echo "\tfetch-process-receita \t\tCaptura os dados da Receita Federal para os fornecedores processados."
	@echo "\tprocess-data anos=<ano1,ano2> filtro=<merenda> \tExecuta o módulo de processamento de dados brutos para o formato usado na aplicação."
	@echo "\t\t\t\t\tAssume um ou mais anos separados por vírgula. Assume que os dados foram baixados."
	@echo "\tprocess-data-empenhos \t\tExecuta o processamento de dados de empenhos."
	@echo "\tprocess-data-novidades \t\tExecuta o processamento de dados de novidades."
	@echo "\tprocess-data-fornecedores anos=<ano1,ano2> \t\tExecuta o processamento de dados de fornecedores."
	@echo "\tprocess-data-itens-similares \t\tExecuta o processamento para agrupar itens similares."
	@echo "\tprocess-data-alertas anos=<ano1,ano2> filtro=<merenda> \t\tExecuta o processamento de dados dos Alertas."
	@echo "\tfeed-create \t\t\tCria as tabelas usadas no Tá na Mesa no Banco de Dados."
	@echo "\tfeed-create-empenho-raw \t\t\tCria a tabela de empenho raw usada para processamento de empenhos."
	@echo "\tfeed-import-data \t\tImporta dados dos CSV's (licitações e contratos) para o Banco de dados."
	@echo "\tfeed-import-empenho \t\tImporta dados do CSV processado de empenhos para o Banco de dados."
	@echo "\tfeed-import-empenho-raw \tImporta dados do CSV de dados brutos vindos do TCE."
	@echo "\tfeed-import-novidade \t\tImporta dados do CSV processado de novidades para o Banco de dados."
	@echo "\tfeed-import-itens-similares-data \t\tImporta os dados dos itens similares para o Banco de dados."
	@echo "\tfeed-import-alerta \t\tImporta dados do CSV processado de alertas para o Banco de dados."
	@echo "\tfeed-update-fornecedores \t\tAtualiza dados do CSV processado de fornecedores para o Banco de dados."
	@echo "\tfeed-shell \t\t\tAbre terminal psql com o banco cadastrado nas variáveis de ambiente."
	@echo "\tfeed-clean-data \t\tRemove as tabelas processadas pelo Tá na Mesa (licitações, contratos e novidades)."
	@echo "\tfeed-clean-empenho \t\tRemove as tabela de empenho (vinda do TCE) carregada no BD do Tá na Mesa."
.PHONY: help
build-fetcher-data-rs:
	docker build -t fetcher-ta-na-mesa fetcher/estados/RS/tce/
.PHONY: build-fetcher-data-rs
fetch-data-rs:
	docker run --rm -it -v `pwd`/data/:/code/scripts/data/ fetcher-ta-na-mesa python3.6 fetch_orgaos.py ./data
	docker run --rm -it -v `pwd`/data/:/code/scripts/data/ fetcher-ta-na-mesa python3.6 fetch_all_data.py $(ano) ./data
.PHONY: fetch-data-rs
fetch-data-pe:		
	docker exec -it r-container sh -c "cd /app/fetcher/estados/PE/tce/ && Rscript fetch_dados_tce_pe.R --data_inicio $(ano_inicial) --data_fim $(ano_final)"
.PHONY: fetch-data-pe
process-data:
	docker exec -it r-container sh -c "cd /app/transformer/processor && Rscript export_dados_bd.R $(anos) $(filtro)"
.PHONY: process-data
process-data-empenhos:
	docker exec -it r-container sh -c "cd /app/transformer/processor && Rscript export_empenhos_bd.R"
.PHONY: process-data-empenhos
process-data-novidades:
	docker exec -it r-container sh -c "cd /app/transformer/processor && Rscript export_novidades_bd.R"
.PHONY: process-data-novidades
process-data-fornecedores:
	docker exec -it r-container sh -c "cd /app/transformer/processor && Rscript export_fornecedores_bd.R $(anos)"
.PHONY: process-data-fornecedores
fetch-process-receita:
	docker exec -it r-container sh -c "cd /app/fetcher/receita &&  Rscript fetch_dados_receita.R"
.PHONY: fetch-process-receita
process-data-itens-similares:
	docker exec -it feed python3.6 /feed/manage.py process-itens-similares
	docker exec -it r-container sh -c "cd /app/transformer/processor/geral/alertas && Rscript export_itens_similares.R"
.PHONY: process-data-itens-similares
process-data-alertas:
	docker exec -it r-container sh -c "cd /app/transformer/processor/geral/alertas && Rscript export_alertas_bd.R $(anos) $(filtro)"
.PHONY: process-data-alertas
feed-create:
	docker exec -it feed python3.6 /feed/manage.py create
.PHONY: feed-create
feed-create-empenho-raw:
	docker exec -it feed python3.6 /feed/manage.py create-empenho-raw
.PHONY: feed-create-empenho-raw
feed-import-itens-similares-data:
	docker exec -it feed python3.6 /feed/manage.py import-itens-similares-data
.PHONY: feed-import-itens-similares-data
feed-import-data:
	docker exec -it feed python3.6 /feed/manage.py import-data
.PHONY: feed-import-data
feed-import-empenho:
	docker exec -it feed python3.6 /feed/manage.py import-empenho
.PHONY: feed-import-empenho
feed-import-empenho-raw:
	docker exec -it feed python3.6 /feed/manage.py import-empenho-raw
.PHONY: feed-import-empenho-raw
feed-import-novidade:
	docker exec -it feed python3.6 /feed/manage.py import-novidade
.PHONY: feed-import-novidade
feed-import-alerta:
	docker exec -it feed python3.6 /feed/manage.py import-alerta
.PHONY: feed-import-alerta
feed-shell:
	docker exec -it feed python3.6 /feed/manage.py shell
.PHONY: feed-shell
feed-update-fornecedores:
	docker exec -it feed python3.6 /feed/manage.py update-fornecedores
.PHONY: feed-update-fornecedores
feed-clean-data:
	docker exec -it feed python3.6 /feed/manage.py clean-data
.PHONY: feed-clean-data
feed-clean-empenho:
	docker exec -it feed python3.6 /feed/manage.py clean-empenho
.PHONY: feed-clean-empenho
