targetScope = 'subscription'

param pName                 string
param pCategory             string
param pVersion              string = '1.0.0'
param pRGName               string
param pNsgName              string

var displayName     = pName
var description     = 'Deploy a network segurity group in the ${pRGName} if not exists.'

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
    /*
      modes are:
        - all: evaluate resource groups, subscriptions, and all resource types
        - indexed: only evaluate resource types that support tags and location
    */
    mode: 'All'
    description: description
    metadata: {
      version: pVersion
      category: pCategory
    }
    policyRule:{
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Resources/subscriptions/resourceGroups'
          }
          {
            field: 'name'
            equals: pRGName
          }
        ]
      }
      then: {
        effect: 'DeployIfNotExists'
        details: {
          type: 'Microsoft.Network/networkSecurityGroups'
          deploymentScope : 'ResourceGroup'
          evaluationDelay: 'AfterProvisioningSuccess'
          roleDefinitionIds: [
            //JLopez-20250825: The b24988ac-6180-42a0-ab88-20f7382dd24c represents the Contributor role.
            //                 You can verify it using the following command: az role definition list --name b24988ac-6180-42a0-ab88-20f7382dd24c
            subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor
          ]
          existenceCondition: {
            field: 'name'
            equals: pNsgName
          }
          deployment: {
            properties: {
              mode: 'Incremental'
              template: {
                schema: 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: pVersion
                resources: [
                  {
                    type: 'Microsoft.Network/networkSecurityGroups'
                    apiVersion: '2023-05-01'
                    name: pNsgName
                    location: myRG.location
                    properties: {}
                  }
                ]
              }
              parameters: {}
            }
          }
        }
      }
    }
  }
}

