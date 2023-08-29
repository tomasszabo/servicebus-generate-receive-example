# Azure ServiceBus Generate-Receive Example

This is example of producing and receiving messages in ServiceBus using Azure Functions.

# Architecture

Architecture consist of:

- ServiceBus
- Azure Function to produce messages and write them to ServiceBus queue
- Azure Function to receive messages from ServiceBus queue
- CosmosDB to store received messages

# Deployment

To deploy required Azure Resources, go to `bicep` directory and execute following Azure CLI command:

```bash
az deployment group create \
    --resource-group {{resourceGroupName}} \
    --name {{deploymentName}} \
    --template-file main.bicep
```

Configure provisioned Azure Functions:

1. Add ServiceBus connection string to `Azure Portal > function-app-1 > Configuration > Application settings > Connection Strings`.
2. Add ServiceBus connection string to `Azure Portal > function-app-2 > Configuration > Application settings > Connection Strings`.
3. Add CosmosDB connection string to `Azure Portal > function-app-2 > Configuration > Application settings > Connection Strings`.

After Azure resources were provisioned and configured, both Azure functions needs to be deployed for example from [Visual Studio Code](https://learn.microsoft.com/en-us/azure/azure-functions/functions-develop-vs-code?tabs=csharp).

# Generate Message

After successful deployment go to `Azure Portal > function-app-1 > GenerateMessage function` and select `Get Function Url`. Add query parameter `message` with some message to the function URL and execute GET HTTP request by opening this URL in browser. Alternatively, you can use POST request with HTTP body:

```json
{
	"message": "your message"
}
```

After successful execution, message is sent to ServiceBus queue.

# Receive Message

After message was generated, second Azure Function is listening for messages in ServiceBus queue. After a message was received, it is written as a new record into CosmosDB database.

# License

Distributed under MIT License. See [LICENSE](LICENSE) for more details.