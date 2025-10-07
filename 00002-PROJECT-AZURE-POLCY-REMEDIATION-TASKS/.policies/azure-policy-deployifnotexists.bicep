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
  source: https://github.com/Azure/azure-policy/tree/master/samples/Network/deploy-network-watcher-when-virtual-network-created
  source: https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effect-deploy-if-not-exists#deployifnotexists-example
  source: https://learn.microsoft.com/en-us/azure/governance/policy/samples/pattern-deploy-resources
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
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Network/networkSecurityGroups'
          resourceGroupName: myRG.name
          existenceCondition: {
            field: 'name'
            equals: pNsgName
          }
          //deploymentScope : 'ResourceGroup'
          evaluationDelay: 'AfterProvisioningSuccess'
          roleDefinitionIds: [
            //JLopez-20250825: The b24988ac-6180-42a0-ab88-20f7382dd24c represents the Contributor role.
            //                 You can verify it using the following command: az role definition list --name 4d97b98b-1d4f-4787-a291-c67834d212e7
            // subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') // Network Contributor
            '/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7' // Network Contributor
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: pVersion
                resources: [
                  {
                    apiVersion: '2020-05-01'
                    type: 'Microsoft.Network/networkSecurityGroups'
                    name: pNsgName
                    location: myRG.location
                    properties: {
                      securityRules: [
                        {
                          name: 'default-allow-rdp'
                          properties: {
                            protocol: 'Tcp'
                            sourcePortRange: '*'
                            sourceAddressPrefix: '*'
                            destinationPortRange: '3389'
                            destinationAddressPrefix: '*'
                            access: 'Allow'
                            priority: 300
                            direction: 'Inbound'
                          }
                        }
                        {
                          name: 'deny-internet-connectivity'
                          properties: {
                            protocol: '*'
                            sourcePortRange: '*'
                            sourceAddressPrefix: '*'
                            destinationPortRange: '*'
                            destinationAddressPrefix: 'Internet'
                            access: 'Deny'
                            priority: 4000
                            direction: 'Outbound'
                          }
                        }
                      ]
                    }
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

