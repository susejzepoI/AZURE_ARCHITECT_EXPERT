
targetScope = 'subscription'

param pName                 string
param pDisplayName          string
param pCategory             string
param pVersion              string = '1.0.0'
param pProject              string
param pLocation             string
param pRGName               string

@allowed(['Project','Environment','Product','Release'])
param pTagName        string = 'Project'

@minLength(5)
@maxLength(20)
param pTagValue       string = 'az305'

var description     = 'Policy to enforce ${pProject} ${pName}'
var tagFieldExpr    = '''[concat('tags[', parameters('tagName'), ']')]'''
var tagValueExpr    = '''[parameters('tagValue')]'''
var displayName     = '${pProject}-${pDisplayName}'
var name            = pName
var AssignmentName  = 'Assignment-${pProject}-${pName}'

/*
  JLopez-20250909: Policy templates.
  Source: https://github.com/Azure/azure-policy/tree/master/built-in-policies
*/
resource myRG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: pRGName
}

resource policyDefinitionEnforceTags 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: name
  properties: {
    displayName: displayName
    policyType: 'Custom'
    mode: 'Indexed'
    description: description
    metadata: {
      version: pVersion
      category: pCategory
    }
    parameters: {
      tagName: {
        type: 'String'
        defaultValue: pTagName
        metadata: {
          displayName: 'Tag Name'
          description: 'The name of the tag to enforce in the resources.'
        }
      }
      tagValue: {
        type: 'String'
        defaultValue: pTagValue
        metadata: {
          displayName: 'Tag Value'
          description: 'The value of the tag to enforce in the resources.'
        }
      }
    }
    policyRule: {
      if: {
        //field: "[concat('tags[', parameters('tagName'), ']')]"
        field: '''[concat('tags[', parameters('tagName'), ']')]'''
        exists: 'false'
      }
      then: {
        effect: 'modify'
        details: {
          roleDefinitionIds: [
            //JLopez-20250825: The b24988ac-6180-42a0-ab88-20f7382dd24c represents the Contributor role.
            //                 You can verify it using the following command: az role definition list --name b24988ac-6180-42a0-ab88-20f7382dd24c
            subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor
          ]
          operations: [
            {
              operation: 'addOrReplace'
              field: tagFieldExpr
              value: tagValueExpr
            }
          ]
        }
      }
    }
  }
}

/*
JLopez-20250823: Assign the policy definition to a scope.
source: https://learn.microsoft.com/en-us/azure/governance/policy/assign-policy-bicep?tabs=azure-powershell
source: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scope-extension-resources
*/
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2024-05-01' = {
  name: AssignmentName
  location: pLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    scope: myRG.id
    displayName: displayName
    description: description
    policyDefinitionId: policyDefinitionEnforceTags.id
    nonComplianceMessages: [
      {
        message: description
      }
    ]
  }
}
