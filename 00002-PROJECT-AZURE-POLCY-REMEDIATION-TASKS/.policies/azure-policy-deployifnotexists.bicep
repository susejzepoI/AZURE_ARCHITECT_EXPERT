targetScope = 'subscription'

param pName                 string
param pDisplayName          string
param pCategory             string
param pVersion              string = '1.0.0'
param pProject              string
param pRGName               string
param pNsgName              string

var displayName     = pDisplayName
var description     = 'Deploy a network segurity group in the ${pRGName} if not exists.'
var AssignmentName  = 'Assignment-${pProject}-${pName}'

/*
  JLopez-20250909: Policy templates.
  source: https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effect-deploy-if-not-exists#deployifnotexists-properties
  Source: https://github.com/Azure/azure-policy/tree/master/built-in-policies
  source: https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effect-deploy-if-not-exists#deployifnotexists-example
*/
resource myRG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: pRGName
}

resource policyDefinitionDeployIfNotExists 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: pName
  properties: {
    displayName: displayName
    policyType: 'Custom'
    mode: 'Indexed'
    description: description
    metadata: {
      version: pVersion
      category: pCategory
    }
    policyRule:{
      if: {
        allof: [
          {
            field: 'type'
            equals: 'Microsoft.Resources/resourceGroups'
          }
          {
            count: {
              field: 'Microsoft.Network/networkSecurityGroups'
            }
            equals: 0
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Network/networkSecurityGroups'
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/de139f84-1756-47ae-9be6-808fbbe84772' // Contributor
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                schema: 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Network/networkSecurityGroups'
                    apiVersion: '2023-05-01'
                    name: pNsgName
                    location: myRG.location
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

resource policyAssignmentDeployIfNotExists 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: AssignmentName
  properties: {
    displayName: AssignmentName
    policyDefinitionId: policyDefinitionDeployIfNotExists.id
    scope: myRG.id
    enforcementMode: 'Default'
  }
}
