#!/bin/bash

set -e

START_DATE="$1"
END_DATE="$2"
OUTPUT_PATH=../data/dados_federais

mkdir -p data/dados_federais

echo $START_DATE
echo $END_DATE

declare -a spiders=(
    "despesa_empenho"
    "despesa_item_empenho"
    "despesa_item_historico"
    "licitacoes"
    "empenhos_relacionados")

cd transparencia_gov

for spider in "${spiders[@]}"; do
    echo $spider
    ./run_interval.sh $spider $START_DATE $END_DATE $OUTPUT_PATH
done
