source .env

echo "stoping $VM_NAME"

docker run -it mcr.microsoft.com/azure-cli sh -c "az login --service-principal -u $APP_ID -p $APP_PASSWORD --tenant $APP_TENANT \
&& az vm deallocate -g $RESOURCE_GROUP -n $VM_NAME"