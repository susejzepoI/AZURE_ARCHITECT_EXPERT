/*JLopez-20250819: Parameters.*/
param pLocation       string = resourceGroup().location
param pAddressPrefix  string = '10.0.0.0/16'
param pSubnetPrefix   string = '10.0.0/24'
param pProject        string

/*JLopez-20250819: Local variables.*/
var pVnetName       = 'vnet-${pProject}-${uniqueString(resourceGroup().id)}'
var psubnetName     = 'subnet-${pProject}-${uniqueString(resourceGroup().id)}'

/*JLopez-20250819: Creating the virtual network and the subnet.*/
resource myVnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: pVnetName
  location: pLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        pAddressPrefix
      ]
    }
    subnets: [
      {
        name: psubnetName
        properties: {
          addressPrefix: pSubnetPrefix
        }
      }
    ]
  }
}

output subnetID string = myVnet.properties.subnets[0].id
