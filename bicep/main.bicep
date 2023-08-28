
@description('Azure location where resources should be deployed (e.g., westeurope)')
@allowed([
  'westeurope'
  'northeurope'
])
param location string = 'westeurope'

module keyVaultModule './keyVault.bicep' = {
  name: 'keyVaultModule'
  params: {
    location: location
  }
}

module databaseModule './database.bicep' = {
  name: 'databaseModule'
  params: {
    location: location
    keyVaultName: keyVaultModule.outputs.keyVaultName
  }
}

module serviceBusModule './serviceBus.bicep' = {
  name: 'serviceBusModule'
  params: {
    location: location
    keyVaultName: keyVaultModule.outputs.keyVaultName
  }
}

module functionModule './function.bicep' = {
  name: 'functionModule'
  params: {
    location: location
    cosmosDbKeyVaultUri: databaseModule.outputs.connectionStringKeyVaultUri
    serviceBusKeyVaultUri: serviceBusModule.outputs.connectionStringKeyVaultUri
  }
}

module keyVaultAccessPolicyModule './keyVaultAccessPolicy.bicep' = { 
  name: 'keyVaultAccessPolicyModule'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    applicationIds: functionModule.outputs.applicationIds
  }
}
