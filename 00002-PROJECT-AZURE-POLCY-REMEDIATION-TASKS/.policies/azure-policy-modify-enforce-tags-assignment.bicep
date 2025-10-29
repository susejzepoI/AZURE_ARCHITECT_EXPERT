
targetScope = 'resourceGroup'

param pName                 string
param pLocation             string

var description     = 'Policy to enforce ${pName}'
var AssignmentName  = 'Assignment-${pName}'

resource policyDefinitionEnforceTags 'Microsoft.Authorization/policyDefinitions@2024-05-01' existing = {
  name: pName
  scope: subscription()
}
/*
JLopez-20250823: Assign the policy definition to a scope.
source: https://learn.microsoft.com/en-us/azure/governance/policy/assign-policy-bicep?tabs=azure-powershell
source: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scope-extension-resources
*/

/*
  JLopez-20250909: Policy templates.
  source: https://learn.microsoft.com/en-us/azure/governance/policy/concepts/assignment-structure#identity
  
  Policy assignment with effect set to deployIfNotExists or modify must have an identity.
*/
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2024-05-01' = {
  name: AssignmentName
  location: pLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: AssignmentName
    description: description
    policyDefinitionId: policyDefinitionEnforceTags.id
    nonComplianceMessages: [
      {
        message: description
      }
    ]
  }
}

output policyAssignmentId string = guid(policyAssignment.id)
