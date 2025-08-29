/*source: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview?tabs=breakdownseries%2Cgeneralsizelist%2Ccomputesizelist%2Cmemorysizelist%2Cstoragesizelist%2Cgpusizelist%2Cfpgasizelist%2Chpcsizelist#compute-optimized*/
@allowed([
  'Standard_A1_v2'
  'Standard_A2_v2'
  'Standard_A4_v2'
  'Standard_A8m_v2'
  'Standard_D2ps_v6'
  'Standard_D16ps_v6'
  'Standard_D48ps_v6'
  'Standard_D96ps_v6'
  'Standard_D2d_v5'
  'Standard_D8d_v5'
  'Standard_D48d_v5'
  'Standard_D96d_v5'
])
param pVmSize string = 'Standard_A1_v2'

@secure()
param pUserName string

@secure()
param pPassword string

param pNicID string
param pLocation string = resourceGroup().location

var pName         = 'vm-${uniqueString(resourceGroup().id)}'
var pComputerName = 'user-${uniqueString(resourceGroup().id)}'


resource linuxVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: pName
  location: pLocation
  properties: {
    hardwareProfile: {
      vmSize: pVmSize
    }
    osProfile: {
      computerName: pComputerName
      adminUsername: pUserName
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
      }
      adminPassword: pPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 30
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: pNicID
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}
