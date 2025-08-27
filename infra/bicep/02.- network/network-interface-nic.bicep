param pVmName     string
param pLocation   string
param pSubnetId   string
param pAllocation string = 'Dynamic' 

var pNicName = '${pVmName}-nic-${uniqueString(resourceGroup().id)}'
var pIpConfigName = '${pVmName}-ipconfig-${uniqueString(resourceGroup().id)}'

/*JLopez-20250826: Creating the network interface.*/
resource mynic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: pNicName
  location: pLocation
  properties: {
    ipConfigurations: [
      {
        name: pIpConfigName
        properties: {
          privateIPAllocationMethod: pAllocation
          subnet: {
            id: pSubnetId
          }
        }
      }
    ]
  }
}

//JLopez-20250826: Returing values using an output variable (source: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/outputs?tabs=azure-powershell).
output nicID string = mynic.id
