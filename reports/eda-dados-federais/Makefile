.DEFAULT_GOAL : help
help:
	@echo "\nEDA - dados federais"
	@echo "Este arquivo a configurar os serviços para o módulo de EDA dos dados federais\n"
	@echo "COMO USAR:\n\t'make <comando>'\n"
	@echo "COMANDOS:"
	@echo "\thelp \t\t\t\tMostra esta mensagem de ajuda"
	@echo "\tcreate-schema \t\t\tCria o schema para exploração dos dados federais"
	@echo "\timport-data \t\t\tImporta os dados federais"
.PHONY: help
.PHONY: build-fetcher-data-rs
create-schema:
	docker exec -it postgres-dados-federais sh -c "psql -d dadosfederais -U postgres -a -f /load/schema.sql"
.PHONY: create-schema
import-data:
	docker exec -it postgres-dados-federais sh -c "psql -d dadosfederais -U postgres -a -f /load/import.sql"
.PHONY: import-data