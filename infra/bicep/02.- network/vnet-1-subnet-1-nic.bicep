/*JLopez-20250819: Parameters.*/
param pLocation       string = resourceGroup().location
param pAddressPrefix  string = '10.0.0.0/16'
param pSubnetPrefix   string = '10.0.0/24'

/*JLopez-20250819: Local variables.*/
var pVnetName       = 'vnet-${uniqueString(resourceGroup().id)}'
var psubnetName     = 'subnet-${uniqueString(resourceGroup().id)}'
var pNicName        = 'nic-${uniqueString(resourceGroup().id)}'
var pIpConfigName   = 'ipconfig-${uniqueString(resourceGroup().id)}'

/*JLopez-20250819: Creating the virtual network and the subnet.*/
resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
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

/*JLopez-20250819: Creating the network interface.*/
resource nic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: pNicName
  location: pLocation
  properties: {
    ipConfigurations: [
      {
        name: pIpConfigName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

