param acrName string 

var pNewOrExisting = acrName == '' ? 'New' : 'Existing'

//JLopez-20251227: 'pACRName' must be unique
var pACRName = acrName == '' ? 'myacr${uniqueString(resourceGroup().id)}' : acrName
/*
  JLopez-20251222: Examples and documentation about Azure Container Registry (ACR) using Bicep.
  https://learn.microsoft.com/en-us/azure/container-registry/container-registry-concepts
  https://github.com/Azure/bicep-registry-modules/blob/main/avm/res/container-registry/registry/main.bicep
*/
// resource MyExitingACR 'Microsoft.ContainerRegistry/registries@2025-11-01' existing = if (pNewOrExisting=='Existing') {
//   scope: resourceGroup()
//   name: acrName
// }

resource MyNewACR 'Microsoft.ContainerRegistry/registries@2025-11-01' = if (pNewOrExisting=='New') {
  name: pACRName
  location: resourceGroup().location
  sku: {
      name: 'Standard'
    }
    properties: {
      adminUserEnabled: true
    }
}
