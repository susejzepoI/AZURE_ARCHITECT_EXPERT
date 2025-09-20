targetScope = 'resourceGroup'

param pName                 string
param pProject              string

var AssignmentName  = '${pProject}-Assignment-${pName}'


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
