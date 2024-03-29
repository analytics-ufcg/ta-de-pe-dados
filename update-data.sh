#!/bin/bash

# SCRIPT PARA AUTOMATIZAR A EXECUÇÃO DO PROCESSAMENTO DE DADOS
# DO TA-DE-PE.

# ==============================================================
#                    VARIÁVEIS E MÉTODOS
# ==============================================================

# Registra a data de início
inicio=$(date +%d-%m-%y_%H:%M)

# Carrega variáveis de ambiente
source .env
# Escreve em arquivo de log
PATH=$PATH:/usr/local/bin
mkdir -p $LOG_FOLDERPATH
timestamp=$(date '+%d_%m_%Y_%H_%M_%S')
log_filepath="${LOG_FOLDERPATH}${timestamp}.txt"
exec > >(tee -a $log_filepath) 2>&1

# Descreve como utilizar o script
usage() {
  echo ""
  echo "Formato: $0 --tipo <tipo> --contexto <contexto> --ano-inicio <ano inicial> --ano-fim <ano final> --data-inicio <data inicial> --data-fim <data final> --estados <ufs>"
  echo -e "\t-t  --tipo         corresponde aos tipos de aplicações (covid e/ou merenda) que serão processadas."
  echo -e "\t-c  --contexto     corresponde ao contexto de destino (production, staging ou development)."
  echo -e "\t-i  --ano-inicio   corresponde ao ano de início do processamento."
  echo -e "\t-f  --ano-fim      corresponde ao ano final do processamento."
  echo -e "\t-f  --data-inicio  corresponde a data de início do processamento (Gov. Federal)."
  echo -e "\t-f  --data-fim     corresponde a data limite do processamento (Gov. Federal)."
  echo -e "\t-f  --estados      corresponde a lista de estados para processamento."
  echo ""
  echo "Ex. de uso: $0 --tipo covid,merenda --contexto development --ano-inicio 2017 --ano-fim 2019 --data-incio 2020-01-01 --data-fim 2022-03-31 --estados RS,PE,BR"
  exit
}

# Adiciona referências para os parâmetros de entrada
while [ $# -gt 0 ]; do
  case "$1" in
  --tipo* | -t*)
    if [[ "$1" != *=* ]]; then shift; fi
    TIPO_APLICACAO="${1#*=}"
    ;;
  --contexto* | -c*)
    if [[ "$1" != *=* ]]; then shift; fi
    CONTEXTO="${1#*=}"
    ;;
  --ano-inicio* | -i*)
    if [[ "$1" != *=* ]]; then shift; fi
    ANO_INICIO="${1#*=}"
    ;;
  --ano-fim* | -f*)
    if [[ "$1" != *=* ]]; then shift; fi
    ANO_FIM="${1#*=}"
    ;;
  --data-inicio* | -f*)
    if [[ "$1" != *=* ]]; then shift; fi
    DATA_INICIO="${1#*=}"
    ;;
  --data-fim* | -f*)
    if [[ "$1" != *=* ]]; then shift; fi
    DATA_FIM="${1#*=}"
    ;;
  --estados* | -f*)
    if [[ "$1" != *=* ]]; then shift; fi
    ESTADOS="${1#*=}"
    ;;
  --help | -h)
    usage
    exit 0
    ;;
  *)
    printf >&2 "Erro ao executar o script: formato inválido de um ou mais argumentos\n"
    usage
    exit 1
    ;;
  esac
  shift
done

# Pretty Print
pprint() {
  printf "\n============================================\n$1\n============================================\n"
}

# Pretty Print
printWithTime() {
  printf "[$(date +%d-%m-%y_%H:%M)] $1 \n"
}

sendDeployInfo() {
  REVISION=$(git rev-parse --verify HEAD)
  LOCAL_USERNAME=$(whoami)
  curl -d '{"environment":"$R_ENV", "revision":"$REVISION", "local_username": "$LOCAL_USERNAME" }' \
  -H "Content-Type: application/json" -H "X-Rollbar-Access-Token: $ROLLBAR_ACCESS_TOKEN" \
  -X POST https://api.rollbar.com/api/1/deploy/
}

# Verifica se os anos de entrada estão corretos
checkParamYear() {
  if [ "$ANO_INICIO" -gt "$ANO_FIM" ]; then
    echo ""
    echo "Erro ao executar o script: a data final deve ser posterior a data inicial."
    usage
  fi

  if [ "$ANO_INICIO" -le 2016 ]; then # apenas contratos de 2017 em diante
    echo ""
    echo "Erro ao executar o script: a data inicial deve ser superior a 2017."
    usage
  fi
}

# Verifica se algum dos parâmetros estão vazios
checkEmptyParam() {
  if [ -z "$TIPO_APLICACAO" ] || [ -z "$CONTEXTO" ] || [ -z "$ANO_INICIO" ] || [ -z "$ANO_FIM" ]; then
    echo ""
    echo "Erro ao executar o script: Alguns ou todos os parâmetros de entrada estão vazios."
    usage
  fi
}

# Concatena anos de acordo com a data de inicio e fim
concatYears() {
  anos=""
  for ((ano = "$ANO_INICIO"; ano <= "$ANO_FIM"; ano++)); do
    anos+=$ano","
  done
  echo ${anos::-1}
}

# exporta arquivo csv
export_csv () {
  zip -r -j $1 $2
}

# ==============================================================
#                           FETCHER
# ==============================================================

# Recupera os dados do Rio Grande do Sul
fetcher_tce_rs() {
  echo ""
  printWithTime "> Executando o download dos dados de $1 do Rio Grande do Sul"
  echo ""
  make fetch-data-rs-all ano="$1"
}

# Recupera os dados de Pernambuco
fetcher_tce_pe() {
  echo ""
  printWithTime "> Executando o download dos dados de Pernambuco"
  echo ""
  make fetch-data-pe ano_inicial=$1 ano_final=$2
}

# Recupera os dados de todos os estados
fetcher_data() {
  IFS=','
  read -a ufs <<< "${ESTADOS}"
  for val in "${ufs[@]}";
  do
    if [[ $val == "RS" ]]
    then
      # RS
      for ((ano = "$ANO_INICIO"; ano <= "$ANO_FIM"; ano++)); do
        fetcher_tce_rs $ano
      done
    fi
    if [[ $val == "PE" ]]
    then
      # PE
      fetcher_tce_pe "$ANO_INICIO" "$ANO_FIM"
    fi
    if [[ $val == "BR" ]]
    then
      # Realiza o fetcher dos dados do Governo Federal
      fetcher_data_federal
    fi
  done
}

# Recupera os dados de empresas inidoneas
fetcher_data_inidoneas() {
  make fetch-inidoneos
}

# Recupera os dados do Governo Federal
fetcher_data_federal() {
  echo ""
  printWithTime "> Executando o download dos dados do Governo Federal"
  echo ""
  make fetch-data-federal data_inicio="$DATA_INICIO" data_fim="$DATA_FIM"
}

# Recupera os dados do Governo Federal já baixados e disponibilizados no google drive
fetcher_data_federal_all_drive() {
  echo ""
  printWithTime "> Executando o download dos dados do Governo Federal do Google Drive"
  echo ""
  make fetch-data-federal-drive
}

# ==============================================================
#                          PROCESSADOR
# ==============================================================

process_data(){
  echo ""
  printWithTime "> Executando o processamento dos dados gerais"
  echo ""
  make process-data anos=$1 filtro=$2 estados=$3
}

# Processa as informações de fornecedores (como data do primeiro 
# contrato e total de contratos)
process_data_fornecedores() {
  echo ""
  printWithTime "> Executando o processamento dos dados dos fornecedores"
  echo ""
  make process-data-fornecedores anos=$1
}

# Processa as informações dos fornecedores com os dados da Receita Federal
process_data_receita_federal() {
  echo ""
  printWithTime "> Executando o processamento dos fornecedores com os dados da Receita Federal"
  echo ""
  make fetch-process-receita
}

# Processa os dados de empenhos
process_data_empenhos(){
  # Verifica se estamos processando o RS pois apenas ele tem empenhos
  IFS=','
  read -a ufs <<< "${ESTADOS}"
  for val in "${ufs[@]}";
  do
    if [[ $val == "RS" ]]
    then
      # RS
      echo ""
      printWithTime "> Executando o processamento dos empenhos (RS)"
      echo ""
      make process-data-empenhos
    fi
  done
}

# Atualiza valores dos empenhos do Governo Federal
process_atualiza_empenhos_federais(){
  # Verifica se estamos processando o BR pois apenas ele precisa atualizar empenhos
  IFS=','
  read -a ufs <<< "${ESTADOS}"
  for val in "${ufs[@]}";
  do
    if [[ $val == "BR" ]]
    then
      # BR
      echo ""
      printWithTime "> Executando a atualização dos empenhos (Governo Federal)"
      echo ""
      make process-atualiza-empenhos-federais
    fi
  done
}

# Atualiza valores dos empenhos do Governo Federal
process_relaciona_itens_empenhos(){
  IFS=','
  read -a ufs <<< "${ESTADOS}"
  for val in "${ufs[@]}";
  do
    if [[ $val == "BR" ]]
    then
      # BR
      echo ""
      printWithTime "> Relacionando o valor final dos itens aos empenhos originais (Governo Federal)"
      echo ""
      make process-relaciona-itens-empenhos
    fi
  done
}

# Processa os dados de novidades
process_data_novidades(){
  echo ""
  printWithTime "> Executando o processamento das novidades"
  echo ""
  make process-data-novidades
}

# Processa os dados de alertas referentes a produtos atípicos
process_data_itens_similares (){
  echo ""
  printWithTime "> Executando o processamento de itens similares"
  echo ""
  make process-data-itens-similares
}

# Processa os dados de alertas referentes a fornecedores contratados logo após a abertura da empresa:
process_data_alertas(){
  echo ""
  printWithTime "> Executando o processamento de alertas"
  echo ""
  make process-data-alertas anos=$1 filtro=$2 estados=$3
}

# Deleta os arquivos csv de empenhos do RS:
delete_empenhos_rs(){
  echo ""
  printWithTime "> Excluindo csvs de empenhos do RS"
  echo ""
  make delete-empenhos-rs
}

# ==============================================================
#                             FEED
# ==============================================================

# cria tabelas
feed_create() {
  echo ""
  printWithTime "> Criando tabelas"
  echo ""
  docker-compose $1 run --rm --no-deps feed python3.6 /feed/manage.py create
}

# Importa dados para as tabelas
feed_import_data() {
  echo ""
  printWithTime "> Importando dados para as tabelas"
  echo ""
  docker-compose $1 run --rm --no-deps feed python3.6 /feed/manage.py import-data
} 

# Cria tabela de empenhos raw (vindos diretamento do TCE-RS)
feed_create_empenho_raw() {
  IFS=','
  read -a ufs <<< "${ESTADOS}"
  for val in "${ufs[@]}";
  do
    if [[ $val == "RS" ]]
    then
      # RS
      echo ""
      printWithTime "> Criando tabela de empenhos (vindos diretamente do TCE-RS)"
      echo ""
      make feed-create-empenho-raw
    fi
  done
}  
  
# Importa os dados de empenhos (vindos diretamento do TCE-RS)
feed_import_empenho_raw() {
  IFS=','
  read -a ufs <<< "${ESTADOS}"
  for val in "${ufs[@]}";
  do
    if [[ $val == "RS" ]]
    then
      # RS
      echo ""
      printWithTime "> Importando os dados de empenhos (vindos diretamente do TCE-RS)"
      echo ""
      make feed-import-empenho-raw
    fi
  done
}  

# Cria tabela de empenhos raw (vindos diretamento do Governo Federal)
feed_create_empenho_raw_gov_federal() {
  IFS=','
  read -a ufs <<< "${ESTADOS}"
  for val in "${ufs[@]}";
  do
    if [[ $val == "BR" ]]
    then
      # BR
      echo ""
      printWithTime "> Criando tabela de empenhos (vindos diretamente do Governo Federal)"
      echo ""
      make feed-clean-empenho-federal
      make feed-create-empenho-raw-gov-federal
    fi
  done
}  
  
# Importa os dados de empenhos (vindos diretamento do Governo Federal)
feed_import_empenho_raw_gov_federal() {
  IFS=','
  read -a ufs <<< "${ESTADOS}"
  for val in "${ufs[@]}";
  do
    if [[ $val == "BR" ]]
    then
      # BR
      echo ""
      printWithTime "> Importando os dados de empenhos (vindos diretamente do Governo Federal)"
      echo ""
      make feed-import-empenho-raw-gov-federal
    fi
  done
}  

# Importa os dados de empenhos processados para o BD
feed_import_empenho () {
  IFS=','
  read -a ufs <<< "${ESTADOS}"
  for val in "${ufs[@]}";
  do
    if [[ $val == "RS" ]]
    then
      # RS
      echo ""
      printWithTime "> Importando os dados de empenhos"
      echo ""
      docker-compose $1 run --rm --no-deps feed python3.6 /feed/manage.py import-empenho
    fi
  done
}

# Importa os dados de novidades para o BD
feed_import_novidade () {
  echo ""
  printWithTime "> Importando os dados de novidades"
  echo ""
  docker-compose $1 run --rm --no-deps feed python3.6 /feed/manage.py import-novidade
}

# Importa para o BD os dados de alertas sobre produtos atípicos:
feed_import_itens_similares_data () {
  echo ""
  printWithTime "> Importando os dados de itens similares"
  echo ""
  docker-compose $1 run --rm --no-deps feed python3.6 /feed/manage.py import-itens-similares-data
}

# Importa para o BD os dados de alertas sobre fornecedores contratados logo após a abertura da empresa
feed_import_alerta () {
  echo ""
  printWithTime "> Importando os dados de alertas"
  echo ""
  docker-compose $1 run --rm --no-deps feed python3.6 /feed/manage.py import-alerta
}

# dropa tabelas
feed_clean_data() {
  echo ""
  printWithTime "> Removendo tabelas (exceto empenhos raw)"
  echo ""
  docker-compose $1 run --rm --no-deps feed python3.6 /feed/manage.py clean-data
}

# ==============================================================
#                           EXECUÇÃO
# ==============================================================

sendDeployInfo
checkEmptyParam
checkParamYear

# Inicia o script caso todos os parâmetros estejam corretos
pprint "Início da execução: $inicio"

echo -e "- Tipo(s) de aplicação: $TIPO_APLICACAO"
echo -e "- Contexto: $CONTEXTO"
echo -e "- Período: $ANO_INICIO até $ANO_FIM ($DATA_INICIO até $DATA_FIM) \n"

# Realiza o fetcher dos dados do RS e de PE e do Governo Federal
fetcher_data

# Realiza o fetcher dos dados de empresas inidoneas
fetcher_data_inidoneas

# Processa os dados de cada estado e cada tipo de aplicação
# entradas dos tipos de aplicação
IFS=',' read -r -a tiposAplicacao <<<"$TIPO_APLICACAO"
# anos concatenados por vírgula
anosConcatenados=$(concatYears)

# Importa os dados de empenhos (vindos diretamente do TCE-RS)
feed_create_empenho_raw
feed_import_empenho_raw

# Deleta os csvs de empenhos do RS
delete_empenhos_rs

# Importa os dados de empenhos (vindos diretamente do Governo Federal)
feed_create_empenho_raw_gov_federal
feed_import_empenho_raw_gov_federal

# iteração para cada tipo de aplicação
for tipoAplicacao in "${tiposAplicacao[@]}"; do

  # remove processamento anterior
  rm -R $PATH_VOLUME_DADOS/bd
  feed_clean_data

  # processa os dados gerais
  process_data "$anosConcatenados" "$tipoAplicacao" "$ESTADOS"
  
  # Processa dos fornecedores
  process_data_fornecedores $anosConcatenados
  
  # Adiciona dados oriundos da RF aos fornecedores
  process_data_receita_federal

  # Processa os empenhos (contratos) relacionados do Governo Federal
  process_atualiza_empenhos_federais

  # Relaciona o preço dos itens dos empenhos relacionados ao empenho original
  process_relaciona_itens_empenhos

  # cria tabelas
  feed_create
  
  # Importa dados para as tabelas
  feed_import_data

  # Processa os dados de empenhos
  process_data_empenhos

  # Processa os dados de novidades
  process_data_novidades

  # Processa os dados de alertas referentes a produtos atípicos
  process_data_itens_similares

  # Processa os dados de alertas referentes a fornecedores contratados logo após a abertura da empresa:
  process_data_alertas $anosConcatenados "$tipoAplicacao" "$ESTADOS"

  # Importa os dados de empenhos processados para o BD
  feed_import_empenho

  # Importa os dados de novidades para o BD
  feed_import_novidade

  # Importa para o BD os dados de alertas sobre produtos atípicos:
  # A tabela importada nesse comando já foi criada pelo process_data_itens_similares
  # feed_import_itens_similares_data

  # Importa para o BD os dados de alertas sobre fornecedores contratados logo após a abertura da empresa
  feed_import_alerta

  if [[ $CONTEXTO == "production" ]] || [[ $CONTEXTO == "staging" ]]
  then
    cfgVarAmbiente="-f docker-compose.yml -f deploy/$CONTEXTO.$tipoAplicacao.yml"
    
    feed_clean_data "$cfgVarAmbiente"
    feed_create "$cfgVarAmbiente"
    feed_import_data "$cfgVarAmbiente"
    feed_import_empenho "$cfgVarAmbiente"
    feed_import_novidade "$cfgVarAmbiente"
    feed_import_itens_similares_data "$cfgVarAmbiente"
    feed_import_alerta "$cfgVarAmbiente"
  fi

  # exporta os dados processados para um arquivo .csv
  pathBackupFile=$(date +%d-%m-%y__%H_%M)
  export_csv "$PATH_VOLUME_DADOS/$tipoAplicacao-bd-${pathBackupFile}.zip" "$PATH_VOLUME_DADOS/bd"
  cp "$PATH_VOLUME_DADOS/$tipoAplicacao-bd-${pathBackupFile}.zip" ./data

done

pprint "Fim da execução: $(date +%d-%m-%y_%H:%M)"

