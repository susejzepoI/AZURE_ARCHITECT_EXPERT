param pLocation string = resourceGroup().location
param pVmSize string = 'standard_a2_v2'
param pComputerName string
@secure()
param pUserName string
@secure()
param pPassword string
param pNicID string

var pName = 'vm-${uniqueString(resourceGroup().id)}'

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: pName
  location: pLocation
  properties: {
    hardwareProfile: {
      vmSize: pVmSize
    }
    osProfile: {
      computerName: pComputerName
      adminUsername: pUserName
      adminPassword: pPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2012-R2-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: pNicID
        }
      ]
    }
  }
}
