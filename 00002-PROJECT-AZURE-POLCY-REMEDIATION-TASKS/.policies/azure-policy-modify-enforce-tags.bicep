
targetScope = 'subscription'

param pName                 string
param pCategory             string
param pVersion              string = '1.0.0'

@allowed(['Project','Environment','Product','Release'])
param pTagName        string = 'Project'

@minLength(2)
@maxLength(20)
param pTagValue       string = 'az305'

var description     = 'Policy to enforce ${pName}'
var tagFieldExpr    = '''[concat('tags[', parameters('tagName'), ']')]'''
var tagValueExpr    = '''[parameters('tagValue')]'''
var displayName     = pName
var name            = pName

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
