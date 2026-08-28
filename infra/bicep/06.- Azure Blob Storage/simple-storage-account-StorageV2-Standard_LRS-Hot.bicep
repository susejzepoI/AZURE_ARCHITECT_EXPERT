param storageAccountName string
param storageAccountLocaltion string
param containerNames array = [
  'starters'
  'mains'
  'desserts'
  'sides'
  'non-alcoholi-beverages'
  'alcoholic-beverages'
  'backups'
]

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

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01' = {
  name: 'default'
  parent: storageAccount
}

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = [for containerName in containerNames: {
  name: containerName
  parent: blobService
  properties: {
    publicAccess: 'None' // Options: 'None', 'Blob', or 'Container'
  }
}]
