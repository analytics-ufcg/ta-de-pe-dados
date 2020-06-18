#!/bin/bash

PATH=$PATH:/usr/local/bin

# Carrega variáveis de ambiente
source .env.update

# Escreve em arquivo de log
exec > >(tee -a $LOG_FILEPATH) 2>&1

# Pretty Print
pprint() {
    printf "\n===============================\n$1\n===============================\n"
}

# Baixa os dados brutos direto do TSE
download_data_tse() {

    pprint "1. Faz o Build do Crawler"
    docker build -t crawler-ta-na-mesa scripts/	

    pprint "2. Faz o Download dos Órgãos"
    docker run --rm -v `pwd`/data/:/code/scripts/data/ crawler-ta-na-mesa python3.6 fetch_orgaos.py ./data

    pprint "3. Faz o Download dos dados brutos"
    docker run --rm -v `pwd`/data/:/code/scripts/data/ crawler-ta-na-mesa python3.6 fetch_all_data.py 2018 ./data 4
    docker run --rm -v `pwd`/data/:/code/scripts/data/ crawler-ta-na-mesa python3.6 fetch_all_data.py 2019 ./data 4
    docker run --rm -v `pwd`/data/:/code/scripts/data/ crawler-ta-na-mesa python3.6 fetch_all_data.py 2020 ./data 4

}

# Executa a atualização completa
run_data_process_update() {

    pprint "1. Levanta serviços"
    docker-compose up -d

    pprint "2. Dropa tabelas"
    docker exec feed python3.6 /feed/manage.py clean-data

    pprint "3. Dropa tabela de empenho"
    docker exec feed python3.6 /feed/manage.py clean-empenho

    pprint "4. Processa dados das tabelas gerais"
    docker exec r-container sh -c "cd /app/code/processor && Rscript export_dados_bd.R 2018,2019,2020"

    pprint "5. Cria schema do BD"
    docker exec feed python3.6 /feed/manage.py create

    pprint "6. Importa dados das tabelas gerais para o BD"
    docker exec feed python3.6 /feed/manage.py import-data

    pprint "7. Importa dados de empenhos para o BD (tabela completa)"
    docker exec feed python3.6 /feed/manage.py import-empenho-raw

    pprint "8. Processa dados de empenhos para considerar apenas merenda"
    docker exec r-container sh -c "cd /app/code/processor && Rscript export_empenhos_bd.R"

    pprint "9. Processa dados de novidades"
    docker exec r-container sh -c "cd /app/code/processor && Rscript export_novidades_bd.R"

    pprint "10. Importa dados de empenhos para o BD"
    docker exec feed python3.6 /feed/manage.py import-empenho

    pprint "11. Importa dados de novidades para o BD"
    docker exec feed python3.6 /feed/manage.py import-novidade

}

run_update_db_remote() {

    pprint "1. Levanta serviço de update de produção"
    docker-compose -f prod.yml up -d

    pprint "2. Dropa tabelas (prod)"
    docker exec feed-prod python3.6 /feed/manage.py clean-data

    pprint "3. Cria schema do BD (prod)"
    docker exec feed-prod python3.6 /feed/manage.py create

    pprint "4. Importa dados das tabelas gerais para o BD (prod)"
    docker exec feed-prod python3.6 /feed/manage.py import-data

    pprint "5. Importa dados de empenhos para o BD (prod)"
    docker exec feed-prod python3.6 /feed/manage.py import-empenho

    pprint "6. Importa dados de novidades para o BD (prod)"
    docker exec feed-prod python3.6 /feed/manage.py import-novidade

}

# Executa toda a atualização
run_full_update() {
    # Baixa dados
    download_data_tse

    # Processa dados
    run_data_process_update
}

# Help
print_usage() {
    printf "Uso Correto: ./update-data.sh <OPERATION_LABEL>\n"
    printf "Operation Labels:\n"
    printf "\t-help: Imprime ajuda para a execução do script\n"
    printf "\t-run-full-update: Executa atualização completa (todos os passos)\n"
    printf "\t-run-data-process-update: Executa o processamento e atualização dos dados localmente \
            (assume que os dados brutos já foram baixados)\n"
    printf "\t-run-update-db-remote: Executa a atualização do Banco de Dados remoto\n"    
    printf "\t-download-data-tse: Faz o Download dos dados do TSE-RS\n"    
}

if [ "$#" -lt 1 ]; then
  echo "Número errado de parâmetros!"
  print_usage
  exit 1
fi

if [[ $@ == *'-help'* ]]; then print_usage; exit 0
fi

pprint "Iniciando atualização"
# Registra a data de início
inicio=$(date +%d-%m-%y_%H:%M)

if [[ $@ == *'-run-full-update'* ]]; then run_full_update
fi

if [[ $@ == *'-run-update-db-remote'* ]]; then run_update_db_remote
fi

if [[ $@ == *'-run-data-process-update'* ]]; then run_data_process_update
fi

if [[ $@ == *'-download-data-tse'* ]]; then download_data_tse
fi

pprint "Início da execução: $inicio"
pprint "Fim da execução: $(date +%d-%m-%y_%H:%M)"
