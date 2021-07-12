## Módulo Azure

Este módulo é responsável por Gerenciar a VM do Azure a nível de produção para o repositório do Tá de pé Dados.

Caso você tenha interesse em realizar o deploy do Tá de pé Dados no Azure então essa configuração pode lhe ajudar.

### Como desligar uma VM Azure de forma automática?

É possível executar o script `stop_azure_vm.sh` para desligar uma VM específica do Azure.

Para realizar tá processo é preciso configurar as variáveis de ambiente necessárias para realizar tal operação.

O método de login/autenticação usado para gerenciar o Azure é via [Service Principal](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli#sign-in-with-a-service-principal).

Portanto é requisito que você crie um service principal para sua conta Azure.
A Microsoft preparou um documento explicando passo a passo que pode ser acessado [aqui](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/active-directory/develop/howto-create-service-principal-portal.md#assign-a-role-to-the-application).

Após ter o service principal configurado certifique-se que você tem o secret gerado por ele para seguir adiante.

1. Dê a autorização necessária para o arquivo `stop_azure_vm.sh` executando:
```
chmod +x stop_azure_vm.sh
```
2. Faça uma cópia do arquivo `.env.sample` para um arquivo `.env`
3. Preencha com os dados correspondentes ao seu contexto.

|variável|explicação|
|---|---|
|APP_ID|Application (client) ID do service principal|
|APP_TENANT|é o Directory (tenant) ID do service principal|
|APP_PASSWORD|é o segredo da autenticação do service principal|
|RESOURCE_GROUP|é o nome do grupo de recursos ao qual a VM pertence|
|VM_NAME|é o nome da VM a qual se deseja parar (dealocação)|
|LOG_FOLDERPATH|é o diretório para salvar os logs da execução (deve conter o / no final)|


4. Por fim, execute o comando que irá parar (dealocar) a VM
```
./stop_azure_vm.sh
```

Você pode explorar o uso desse script:
1. Mudando qual grupo de recurso ou qual VM você deseja parar.
2. Mudando o comando do azure cli para ao invés de parar realizar outra operação desejada (tome cuidado!).
