targetScope = 'subscription'

param pName                 string
param pCategory             string
param pVersion              string = '1.0.0.0'
param pRGName               string
param pNsgName              string

var displayName     = pName
var description     = 'Modify all the NIC within the ${pRGName} resource group to add the NSG ${pNsgName}.'

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: pNsgName
  scope: resourceGroup(pRGName)
}

resource policyDefinitionModifyNicToAddNsg 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: pName
  properties: {
    displayName: displayName
    policyType: 'Custom'
    /*
      modes are:
        - all: evaluate resource groups, subscriptions, and all resource types
        - indexed: only evaluate resource types that support tags and location
    */
    mode: 'Indexed'
    description: description
    metadata: {
      version: pVersion
      category: pCategory
    }
    parameters: {}
    policyRule: {
      /*
        JLopez-20251013: 
        Check available aliases
        Get-AzPolicyAlias | Select-Object -ExpandProperty 'Aliases' | Where-Object { $_.DefaultMetadata.Attributes -eq 'Modifiable'} | Where-object {$_.Name -like "*networkinterface*"} | select-object "name"
      */
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Network/networkInterfaces'
          }
        ]
      }
      then: {
        effect: 'modify'
        details: {
          roleDefinitionIds: [
            //JLopez-20250825: The b24988ac-6180-42a0-ab88-20f7382dd24c represents the Contributor role.
            //                 You can verify it using the following command: az role definition list --name 4d97b98b-1d4f-4787-a291-c67834d212e7
            '/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7' // Network Contributor
          ]
          operations: [
            {
              operation: 'Add'
              field: 'Microsoft.Network/networkInterfaces/networkSecurityGroup'
              value: {
                id: nsg.id
              }
              condition: {
                field: 'Microsoft.Network/networkInterfaces/networkSecurityGroup.id'
                exists: false
              }
            }
          ]
        }
      }
    }
  }
}
