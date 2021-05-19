#!/bin/bash

# SCRIPT PARA AUTOMATIZAR A EXECUÇÃO DO PROCESSAMENTO DE DADOS
# DO TA-DE-PE.

# ==============================================================
#                    VARIÁVEIS E MÉTODOS
# ==============================================================

# Registra a data de início
inicio=$(date +%d-%m-%y_%H:%M)

# Carrega variáveis de ambiente
source .env.update

# Escreve em arquivo de log
PATH=$PATH:/usr/local/bin
mkdir -p $LOG_FOLDERPATH
timestamp=$(date '+%d_%m_%Y_%H_%M_%S')
log_filepath="${LOG_FOLDERPATH}${timestamp}.txt"
exec > >(tee -a $log_filepath) 2>&1

# Descreve como utilizar o script
usage() {
  echo ""
  echo "Formato: $0 --tipo <tipo> --contexto <contexto> --ano-inicio <ano inicial> --ano-fim <ano final>"
  echo -e "\t-t  --tipo        corresponde aos tipos de aplicações (covid e/ou merenda) que serão processadas."
  echo -e "\t-c  --contexto    corresponde ao contexto de destino (remoto ou local)."
  echo -e "\t-i  --data_inicio corresponde ao ano de início do processamento."
  echo -e "\t-f  --data_fim    corresponde ao ano final do processamento."
  echo ""
  echo "Ex. de uso: $0 --tipo covid,merenda --contexto local --ano-inicio 2017 --ano-fim 2019"
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

# ==============================================================
#                           FETCHER
# ==============================================================

# Recupera os dados do Rio Grande do Sul
fetcher_tce_rs() {
  echo ""
  printWithTime "> Executando o download dos dados de $1 do Rio Grande do Sul"
  echo ""
  make fetch-data-rs ano="$1"
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
  # RS
  for ((ano = "$ANO_INICIO"; ano <= "$ANO_FIM"; ano++)); do
    fetcher_tce_rs $ano
  done

  # PE
  fetcher_tce_pe "$ANO_INICIO" "$ANO_FIM"
}

# ==============================================================
#                          PROCESSADOR
# ==============================================================

process_data(){
  echo ""
  printWithTime "> Executando o processamento dos dados gerais"
  echo ""
  make process-data anos=$1 filtro=$2
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

# ==============================================================
#                           EXECUÇÃO
# ==============================================================

checkEmptyParam
checkParamYear

# Inicia o script caso todos os parâmetros estejam corretos
pprint "Início da execução: $inicio"

echo -e "- Tipo(s) de aplicação: $TIPO_APLICACAO"
echo -e "- Contexto: $CONTEXTO"
echo -e "- Período: $ANO_INICIO até $ANO_FIM \n"

# Realiza o fetcher dos dados do RS e de PE
# fetcher_data

# Processa os dados de cada estado e cada tipo de aplicação
# entradas dos tipos de aplicação
IFS=',' read -r -a tiposAplicacao <<<"$TIPO_APLICACAO"
# anos concatenados por vírgula
anosConcatenados=$(concatYears)

# iteração para cada tipo de aplicação
for tipoAplicacao in "${tiposAplicacao[@]}"; do
  # processa os dados gerais
  process_data $anosConcatenados "$tipoAplicacao"
  
  # Processa dos dos fornecedores
  process_data_fornecedores $anosConcatenados
  
  # Adiciona dados oriundos da RF aos fornecedores
  process_data_receita_federal
  
  # VERIFICA/ALTERA DOCKER AQUI?

  # cria tabelas
  make feed-create
  
  #Importa dados para as tabelas
  make feed-import-data

  #Importa os dados de empenhos (vindos diretamento do TCE)
  make feed-import-empenho-raw

  # Processa os dados de empenhos
  make process-data-empenhos

  # Processa os dados de novidades
  make process-data-novidades

  # Processa os dados de alertas referentes a produtos atípicos
  make process-data-itens-similares

  # Processa os dados de alertas referentes a fornecedores contratados logo após a abertura da empresa:
  make process-data-alertas anos=2018,2019,2020,2021 filtro=merenda

  # Importa os dados de empenhos processados para o BD
  make feed-import-empenho

  # Importa os dados de novidades para o BD
  make feed-import-novidade

  # Importa para o BD os dados de alertas sobre produtos atípicos:
  make feed-import-itens-similares-data

  # Importa para o BD os dados de alertas sobre fornecedores contratados logo após a abertura da empresa
  make feed-import-alerta
done



pprint "Fim da execução: $(date +%d-%m-%y_%H:%M)"

