param webAppName string
param appServicePlanName string
param location string


resource appServicePlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'F1'
  }
  kind: 'linux'
  properties:{
    reserved: true
  }
}

resource webapp_site 'Microsoft.Web/sites@2025-03-01'= {
  name: webAppName
  location: location
  kind: 'linux'
  properties: {
    enabled: true
    reserved: true
    httpsOnly: true
    publicNetworkAccess: 'Enabled'
    ipMode: 'IPv4'
    serverFarmId: appServicePlan.id
    siteConfig:{
      numberOfWorkers: 1
      linuxFxVersion: 'DOTNETCORE|10.0'
    }
  }
}

