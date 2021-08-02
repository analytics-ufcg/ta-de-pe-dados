#!/bin/bash

source .env

echo "stoping $VM_NAME"

mkdir -p $LOG_FOLDERPATH
timestamp=$(date '+%d_%m_%Y_%H_%M_%S')
log_filepath="${LOG_FOLDERPATH}${timestamp}.txt"
exec > >(tee -a $log_filepath) 2>&1

docker run mcr.microsoft.com/azure-cli sh -c "az login --service-principal -u $APP_ID -p $APP_PASSWORD --tenant $APP_TENANT \
&& az vm deallocate -g $RESOURCE_GROUP -n $VM_NAME"
