param pLocation string = resourceGroup().location

var pName = 'nic-${uniqueString(resourceGroup().id)}'

resource networkInterface 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: pName
  location: pLocation
  properties: {
    ipConfigurations: [
      {
        name: 'name'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: 'subnet.id'
          }
        }
      }
    ]
  }
}

