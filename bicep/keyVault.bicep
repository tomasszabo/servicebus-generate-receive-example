
param location string
param keyVaultName string = 'keyvault-${uniqueString(resourceGroup().id)}'

resource vault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    accessPolicies:[]
    enableRbacAuthorization: false
    enableSoftDelete: false
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

output keyVaultName string = keyVaultName
