param pAssignmentName   string
param pDefinitionID     string
param pDisplayName      string
param pDescription      string
param pMessage          string
param pProject          string

var assignmentName  = '${pProject}-${pAssignmentName}'
var displayName     = '${pProject}-${pDisplayName}'
var description     = '${pProject}-${pDescription}'
var message         = '${pProject}-${pMessage}'

/*
JLopez-20250823: Assign the policy definition to a scope.
source: https://learn.microsoft.com/en-us/azure/governance/policy/assign-policy-bicep?tabs=azure-powershell
*/
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2024-05-01' = {
  name: assignmentName
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: displayName
    description: description
    policyDefinitionId: pDefinitionID
    scope: resourceGroup().id
    nonComplianceMessages: [
      {
        message: message
      }
    ]
  }
}
