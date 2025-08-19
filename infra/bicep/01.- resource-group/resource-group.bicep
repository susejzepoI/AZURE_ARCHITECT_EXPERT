targetScope = 'subscription'

param pLocation   string = 'eastus'
param pName       string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: pName
  location: pLocation
}
