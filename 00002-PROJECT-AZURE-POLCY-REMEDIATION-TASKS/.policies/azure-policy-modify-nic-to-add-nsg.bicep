targetScope = 'subscription'

param pName                 string
param pCategory             string
param pVersion              string = '1.0.0.0'
param pRGName               string
param pNsgName              string

var displayName     = pName
var description     = 'Modify all the NIC within the ${pRGName} resource group to add the NSG ${pNsgName}.'

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
    parameters: {
      rgName: {
        type: 'String'
        defaultValue: pRGName
        metadata: {
          displayName: 'Resource Group Name'
          description: 'The name of the resource group where the NICs are deployed.'
        }
      }
      nsgName: {
        type: 'String'
        defaultValue: pNsgName
        metadata: {
          displayName: 'Network Security Group Name'
          description: 'The name of the Network Security Group to associate with the NICs.'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'resourceGroup'
            equals: '''[parameters('pRGName')]'''
          }
          {
            field: 'type'
            equals: 'Microsoft.Network/networkInterfaces'
          }
          {
            field: 'Microsoft.Network/networkInterfaces/networkSecurityGroup.id'
            equals: ''
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
              operation: 'addOrReplace'
              field: 'Microsoft.Network/networkInterfaces/networkSecurityGroup'
              value: {
                id: '''[resourceId('Microsoft.Network/networkSecurityGroups', parameters('nsgName'))]'''
              }
            }
          ]
        }
      }
    }
  }
}
