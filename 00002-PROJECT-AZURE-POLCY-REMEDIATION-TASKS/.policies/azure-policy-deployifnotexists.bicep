targetScope = 'subscription'

param pName                 string
param pDisplayName          string
param pCategory             string
param pVersion              string = '1.0.0'
param pProject              string
param pRGName               string

var description     = 'Deploy a network segurity group in the ${pRGName} if not exists.'
var AssignmentName  = 'Assignment-${pProject}-${pName}'

/*
  JLopez-20250909: Policy templates.
  Source: https://github.com/Azure/azure-policy/tree/master/samples/built-in-policy
*/
resource myRG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: pRGName
}

resource policyDeployIfNotExists 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: pName
  properties: {
    displayName: pDisplayName
    policyType: 'Custom'
    mode: 'All'
    description: 'This policy denies the creation of resources in locations that are not explicitly allowed.'
    metadata: {
      version: pVersion
      category: pCategory
    }
    parameters: {
      allowedLocations: {
        type: 'Array'
        metadata: {
          displayName: pDisplayName
          description: description
        }
      }
    }
   }
}

resource policyAssignmentDeployIfNotExists 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: AssignmentName
  properties: {
    displayName: AssignmentName
    policyDefinitionId: policyDeployIfNotExists.id
    scope: myRG.id
    enforcementMode: 'Default'
  }
}
