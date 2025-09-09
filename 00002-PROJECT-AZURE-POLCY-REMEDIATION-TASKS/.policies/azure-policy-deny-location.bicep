targetScope = 'subscription'

param pName                 string
@allowed(['westus','Brazil'])
param pLocation             string
param pDisplayName          string
param pCategory             string
param pVersion              string = '1.0.0'
param pProject              string

var description     = 'Policy to deny deployments on: ${pLocation}.'
var displayName     = pDisplayName
var name            = pName
var tagExpr         = '''[parameters('allowedLocations')]'''
var AssignmentName  = 'Assignment-${pProject}-${pName}'

resource policyDenyLocation 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: name
  properties: {
    displayName: displayName
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
          displayName: displayName
          description: description
        }
      }
    }
    policyRule: {
      if: {
        field: 'location'
        notIn: tagExpr
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

// /*JLopez-20250908: Getting the resource group definition.*/
// resource myRG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
//   name: pResourceGroupName
// }

resource policyAssignmentDenyLocation 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: AssignmentName
  properties: {
    displayName: displayName
    policyDefinitionId: policyDenyLocation.id
    parameters: {
      allowedLocations: {
        value: [
          pLocation
        ]
      }
    }
  }
}
