## What is the project about?
The aimd of the project 00002 is to test how Azure policies works and how can they be deployed using bicep. The *main.ps1* deploys four azure policies across two different resources groups. Then it deploys network resources to implement virtual machines within these two groups.

## Which resource groups are created in this deployment?
* The resource group *00002-tags-deployifnotexists-nsg*. The main purpose for this rg is to test different azure policies include the enforce tag policy, the deploy if not exists policy and thhe modify to add a network segurity group policy.

* The resource group *00002-deny-locations*. The main purpose for this rg is to test how the deny location policy works when a deployment tries to deploy resources in denied locations.

## Which policies are created in this deployment?
* Policy *azure-policy-modify-enforce-tags.bicep*. Applies to all resources groups. It enforce the tag value pass throw the script in all the resources being to be deployed.
* Policy *azure-policy-deny-location.bicep*. Applies only to the *00002-deny-locations* resource group. It only allows deployments in westus or eastus regions.
* Policy *azure-policy-deployifnotexists.bicep*. Applies only to the *00002-tags-deployifnotexists-nsg* resource group. It deploys a network segurity group if not exists.
* Policy *azure-policy-modify-nic-to-add-nsg.bicep*. Applies only to the *00002-tags-deployifnotexists-nsg* resource group. It modifies the current network interface deployed with the virtual machine to add a references to the new network segurity group created before.

## Which roles or permissions do you need?
In order to execute this project you must have at least these roles:
* Contributor
* Resource Policy Contributor
* User Access Administrator

Or you can created a custom role with these permissions

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