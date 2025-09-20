targetScope = 'resourceGroup'

param pName                 string
@allowed(['westus','Brazil'])
param pLocation             string
param pDisplayName          string
param pProject              string

var AssignmentName  = '${pProject}-Assignment-${pName}'

/*
  JLopez-20250909: Policy templates.
  Source: https://github.com/Azure/azure-policy/tree/master/built-in-policies
*/
resource policyDefinitionDenyLocation 'Microsoft.Authorization/policyDefinitions@2020-03-01' existing = {
  name: pName
  scope: subscription()
}

resource policyAssignmentDenyLocation 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: AssignmentName
  scope: resourceGroup()
  properties: {
    displayName: pDisplayName
    policyDefinitionId: policyDefinitionDenyLocation.id
    parameters: {
      allowedLocations: {
        value: [
          pLocation
        ]
      }
    }
  }
}
