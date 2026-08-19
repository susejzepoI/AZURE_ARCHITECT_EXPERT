param storageAccountName string
param storageAccountLocaltion string

resource storageAccount 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  kind: 'StorageV2'
  location: storageAccountLocaltion
  name: storageAccountName
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    minimumTlsVersion: 'TLS1_2'
  }
}
