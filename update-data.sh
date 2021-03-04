#!/bin/bash

PATH=$PATH:/usr/local/bin

# Carrega variáveis de ambiente
source .env.update

# Escreve em arquivo de log
mkdir -p $LOG_FOLDERPATH
timestamp=$(date '+%d_%m_%Y_%H_%M_%S');
log_filepath="${LOG_FOLDERPATH}${timestamp}.txt"
exec > >(tee -a $log_filepath) 2>&1

# Pretty Print
pprint() {
    printf "\n===============================\n$1\n===============================\n"
}

# Baixa os dados brutos direto do TCE
download_data_tce_rs() {
    anosP=$1

    pprint "1. Faz o Build do fetcher"
    docker build -t fetcher-ta-na-mesa scripts/

    pprint "2. Faz o Download dos Órgãos"
    docker run --rm -v `pwd`/data/:/code/scripts/data/ fetch-data-rs python3.6 fetch_orgaos.py ./data

    pprint "3. Faz o Download dos dados brutos"

    IFS=',' read -r -a anos <<< "$anosP"
    for ano in "${anos[@]}"
    do
        pprint "Baixando $ano"
        docker run --rm -v `pwd`/data/:/code/scripts/data/ fetch-data-rs python3.6 fetch_all_data.py "$ano" ./data 4
    done
}

# Executa a atualização completa
run_data_process_update() {
    anosDownload=$1
    anosFiltro=$2
    filtro=$3
    atualiza_empenhos_raw=$4

    pprint "Processando para $anosFiltro com o filtro $filtro"

    pprint "Levanta serviços"
    docker-compose up -d

    pprint "Dropa tabelas"
    docker exec feed python3.6 /feed/manage.py clean-data

    pprint "Processa dados das tabelas gerais"
    docker exec r-container sh -c "cd /app/code/processor && Rscript export_dados_bd.R $anosFiltro $filtro"

    pprint "Atualiza dados de fornecedores"
    docker exec r-container sh -c "cd /app/code/processor && Rscript export_fornecedores_bd.R $anosDownload"

    pprint "Processa dados da Receita"
    docker exec -it r-container sh -c "cd /fetcher/receita &&  Rscript fetch_dados_receita.R"

    pprint "Cria schema do BD"
    docker exec feed python3.6 /feed/manage.py create

    pprint "Importa dados das tabelas gerais para o BD"
    docker exec feed python3.6 /feed/manage.py import-data

    if [[ $atualiza_empenhos_raw == 1 ]]; 
	then 
        pprint "Dropa tabela de empenho raw"
        docker exec feed python3.6 /feed/manage.py clean-empenho

        pprint "Cria tabela de empenho raw"
        docker exec -it feed python3.6 /feed/manage.py create-empenho-raw

        pprint "Importa dados de empenhos para o BD (tabela completa)"
        docker exec feed python3.6 /feed/manage.py import-empenho-raw
    fi

    pprint "Processa dados de empenhos para considerar apenas os das licitações filtradas"
    docker exec r-container sh -c "cd /app/code/processor && Rscript export_empenhos_bd.R"

    pprint "Processa dados de novidades"
    docker exec r-container sh -c "cd /app/code/processor && Rscript export_novidades_bd.R"

    pprint "Processa dados de itens similares"
    docker exec -it feed python3.6 /feed/manage.py process-itens-similares
	docker exec -it r-container sh -c "cd /app/code/processor/ && Rscript export_itens_similares.R"

    pprint "Processa dados de alertas"
    docker exec -it r-container sh -c "cd /app/code/processor && Rscript export_alertas_bd.R $anosDownload $filtro"

    pprint "Importa dados de empenhos para o BD"
    docker exec feed python3.6 /feed/manage.py import-empenho

    pprint "Importa dados de novidades para o BD"
    docker exec feed python3.6 /feed/manage.py import-novidade

    pprint "Importa dados de itens similares"
    docker exec -it feed python3.6 /feed/manage.py import-itens-similares-data

    pprint "Importa dados de alertas"
    docker exec -it feed python3.6 /feed/manage.py import-alerta

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
    download_data_tce_rs "2018,2019,2020"

    # Processa dados
    run_data_process_update "2018,2019,2020" "2018,2019,2020" "merenda" 1
}

# Help
print_usage() {
    printf "Uso Correto: ./update-data.sh <OPERAÇÃO> <ANOS> <FILTRO> <EMPENHOS_RAW>\n"
    printf "Operações:\n"
    printf "\t-help: Imprime ajuda para a execução do script\n"
    printf "\t-run-full-update: Executa atualização completa (todos os passos)\n"
    printf "\t-process-update <anosDownload> <anosFiltro> <filtro>: Executa o processamento e atualização dos dados localmente\n \
            \t(assume que os dados brutos já foram baixados)\n \
            \tAnos para Download é uma string com os anos de download separados por vírgula. Exemplo: '2019,2020'.\n \
            \tAnos para filtro é uma string com os anos par filtro das licitações. Exemplo: '2019,2020'.\n \
            \tFiltro é o assunto para processamento das licitações. Pode ser 'merenda' ou 'covid'.\n \
            \Empenhos Raw é uma flag para atualizar ou não os empenhos brutos (1 para atualizar, 0 para usar versão atual).\n"
    printf "\t-run-update-db-remote: Executa a atualização do Banco de Dados remoto\n"
    printf "\t-download-data-tce-rs <anos>: Faz o Download dos dados do TCE-RS.\n \
            \tAnos é uma string com os anos para download separados por vírgula. Exemplo: '2019,2020'.\n"
}

if [[ $@ == *'-help'* ]]; then print_usage; exit 0
fi

if [ "$#" -lt 4 ]; then
  echo "Número errado de parâmetros!"
  print_usage
  exit 1
fi

pprint "Iniciando atualização"
# Registra a data de início
inicio=$(date +%d-%m-%y_%H:%M)

if [[ $@ == *'-run-full-update'* ]]; then run_full_update
fi

if [[ $@ == *'-run-update-db-remote'* ]]; then run_update_db_remote
fi

if [[ $@ == *'-process-update'* ]]; then run_data_process_update "$2" "$3" "$4" "$5"
fi

if [[ $@ == *'-download-data-tce-rs'* ]]; then download_data_tce_rs "$2"
fi

pprint "Início da execução: $inicio"
pprint "Fim da execução: $(date +%d-%m-%y_%H:%M)"
