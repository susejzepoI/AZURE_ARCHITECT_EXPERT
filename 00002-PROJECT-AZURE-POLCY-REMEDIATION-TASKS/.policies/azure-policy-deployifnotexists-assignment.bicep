targetScope = 'resourceGroup'

param pName                 string

var AssignmentName      = 'Assignment-${pName}'
var RBACAssignmentName  = 'RBAC-${pName}'

resource policyDefinitionDeployIfNotExists 'Microsoft.Authorization/policyDefinitions@2020-03-01' existing = {
  name: pName
  scope: subscription()
}

/*
  JLopez-20250909: Policy templates.
  source: https://learn.microsoft.com/en-us/azure/governance/policy/concepts/assignment-structure#identity
  
  Policy assignment with effect set to deployIfNotExists or modify must have an identity.
*/
resource policyAssignmentDeployIfNotExists 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: AssignmentName
  scope: resourceGroup()
  location: resourceGroup().location
  properties: {
    displayName: AssignmentName
    policyDefinitionId: policyDefinitionDeployIfNotExists.id
    enforcementMode: 'Default'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

//JLopez-20251001: Grant the assignment managed identity the necessary permissions on this resource group.
resource RBACRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(RBACAssignmentName)
  scope: resourceGroup() 
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'
    principalId: policyAssignmentDeployIfNotExists.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
