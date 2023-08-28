
param location string
param cosmosDbKeyVaultUri string
param serviceBusKeyVaultUri string
param suffix string = uniqueString(resourceGroup().id)
param storageAccountName string = 'fstorage${suffix}'
param hostingPlan1Name string = 'function-asp-1-${suffix}'
param functionApp1Name string = 'function-app-1-${suffix}'
param hostingPlan2Name string = 'function-asp-2-${suffix}'
param functionApp2Name string = 'function-app-2-${suffix}'
param applicationInsightsName string = 'app-insights-${suffix}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource hostingPlan1 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlan1Name
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

resource hostingPlan2 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlan2Name
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource functionApp1 'Microsoft.Web/sites@2022-03-01' = {
  name: functionApp1Name
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan1.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionApp1Name)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
      connectionStrings: [
        {
          name: 'ServiceBus'
          type: 'Custom'
          connectionString: '@Microsoft.KeyVault(SecretUri=${serviceBusKeyVaultUri})'
        }
      ]
      cors: {
        allowedOrigins: [
          '*'
        ]
      }
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      use32BitWorkerProcess: false
      netFrameworkVersion: '6.0'
    }
    
    httpsOnly: true
  }
}

resource functionApp2 'Microsoft.Web/sites@2022-03-01' = {
  name: functionApp2Name
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan2.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionApp2Name)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
      connectionStrings: [
        {
          name: 'CosmosDB'
          type: 'Custom'
          connectionString: '@Microsoft.KeyVault(SecretUri=${cosmosDbKeyVaultUri})'
        }
        {
          name: 'ServiceBus'
          type: 'Custom'
          connectionString: '@Microsoft.KeyVault(SecretUri=${serviceBusKeyVaultUri})'
        }
      ]
      cors: {
        allowedOrigins: [
          '*'
        ]
      }
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      use32BitWorkerProcess: false
      netFrameworkVersion: '6.0'
    }
    
    httpsOnly: true
  }
}

output applicationIds array = [functionApp1.identity.principalId, functionApp2.identity.principalId]
