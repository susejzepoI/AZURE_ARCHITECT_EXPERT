param webAppName string
param appServicePlanName string
param location string


resource appServicePlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'linux'
}

resource webapp_site 'Microsoft.Web/sites@2025-03-01'= {
  name: webAppName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
  }
}

