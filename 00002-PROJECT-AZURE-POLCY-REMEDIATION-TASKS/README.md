## What is the project about?
The aimd of the project 00002 is to test how Azure policies work and how can they be deployed using bicep. The *main.ps1* scripts deploys four Azure Policies across two different resources groups (RG). It then deploys the necessary network resources to create virtual machines within these two RG.

## Which resource groups are created in this deployment?
* __The 00002-tags-deployifnotexists-nsg resource group__. Is used to test several Azure policies, such as the *enforce tag policy*, the *DeployIfNotExists policy* and the *modify policy* to add a network segurity group policy.

* __The 00002-deny-locations resource group__. Is used to test how the Deny location behaves when a deployment attempts to create a resource in restricted locations.

## Which policies are created in this deployment?
* __The azure-policy-modify-enforce-tags.bicep policy__. Applies to all resources groups. It enforces the tag value pass through the script on all resources being to be deployed.
* __The azure-policy-deny-location.bicep policy__. Applies only to the *00002-deny-locations* RG. It allows deployments *only* in __westus__ or __eastus__ regions.
* __The azure-policy-deployifnotexists.bicep policy__. Applies only to the *00002-tags-deployifnotexists-nsg* RG. It deploys a __Network Segurity Group (NSG)__ if one does not exists.
* __The azure-policy-modify-nic-to-add-nsg.bicep policy__. Applies only to the *00002-tags-deployifnotexists-nsg* RG. It modifies the network interface deployed with the virtual machine to add a references to the NSG previously created.

## Which roles or permissions do you need?
In order to execute this project, you must have at least the following roles:
* Contributor
* Resource Policy Contributor
* User Access Administrator

Alternatively, you can create a custom role that includes these permissions:

```json
    {
        "id": "/subscriptions/24c299fa-aec1-489b-8cf2-671209727540/providers/Microsoft.Authorization/roleDefinitions/1d046d31-81e2-4fc8-bb32-c818594bb410",
        "properties": {
            "roleName": "00002_bicep_deployment_role",
            "description": "",
            "assignableScopes": [
                "/subscriptions/24c299fa-aec1-489b-8cf2-671209727540"
            ],
            "permissions": [
                {
                    "actions": [
                        "*",
                        "Microsoft.Authorization/acquirePolicyToken/read",
                        "Microsoft.Authorization/policyAssignments/read",
                        "Microsoft.Authorization/policyAssignments/write",
                        "Microsoft.Authorization/policyDefinitions/read",
                        "Microsoft.Authorization/policyDefinitions/write",
                        "Microsoft.Authorization/policyDefinitions/versions/write",
                        "Microsoft.Authorization/policyEnrollments/write",
                        "Microsoft.Authorization/policyEnrollments/read",
                        "Microsoft.Authorization/policyDefinitions/versions/read",
                        "Microsoft.Authorization/policySetDefinitions/write",
                        "Microsoft.Authorization/policySetDefinitions/read",
                        "Microsoft.Authorization/policySetDefinitions/versions/write",
                        "Microsoft.Authorization/policySetDefinitions/versions/read",
                        "Microsoft.Authorization/roleManagementPolicyAssignments/read"
                    ],
                    "notActions": [
                        "Microsoft.Authorization/*/Delete",
                        "Microsoft.Authorization/*/Write",
                        "Microsoft.Authorization/elevateAccess/Action",
                        "Microsoft.Blueprint/blueprintAssignments/write",
                        "Microsoft.Blueprint/blueprintAssignments/delete",
                        "Microsoft.Compute/galleries/share/action",
                        "Microsoft.Purview/consents/write",
                        "Microsoft.Purview/consents/delete",
                        "Microsoft.Resources/deploymentStacks/manageDenySetting/action",
                        "Microsoft.Subscription/cancel/action",
                        "Microsoft.Subscription/enable/action"
                    ],
                    "dataActions": [],
                    "notDataActions": []
                }
            ]
        }
    }
```

#### 3. Run the main scripts
To run this project, first navigate into the corresponding sub-project folder and then execute the main PowerShell file. An example is provided below:

```sh
cd .\00002-PROJECT-AZURE-POLCY-REMEDIATION-TASKS\

.\main.ps1 `
            -ProjectTagName "Environment" `
            -ProjectTagValue "QA" `
            -pPassword $password
```

## Credits
This repository was initially created by [Jesus Lopez](https://www.linkedin.com/in/susejzepol/). Its purpose is to support learning and hands-on practice for the [AZ-305](https://learn.microsoft.com/en-us/credentials/certifications/exams/az-305/) and [AZ-104](https://learn.microsoft.com/en-us/credentials/certifications/azure-administrator/?practice-assessment-type=certification) certification exams, as well as to explore various Azure technologies.