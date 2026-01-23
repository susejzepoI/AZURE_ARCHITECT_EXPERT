# 00002 - Project: Azure Policy and Remediation Tasks

## Project Overview

### What the Project Does

This project demonstrates advanced Azure governance through **Azure Policy** implementation and enforcement. The solution deploys and tests multiple policy types across two resource groups with real-world scenarios:

- Four distinct Azure Policy definitions using Bicep Infrastructure-as-Code
- Network infrastructure (Virtual Networks, Subnets, Network Interface Cards)
- Virtual machines (Windows and Linux) for policy testing
- Policy assignment, remediation, and enforcement patterns
- End-to-end orchestration via PowerShell

### Problem It Solves

This project serves as a hands-on learning resource for:

- Understanding Azure Policy enforcement mechanisms (Deny, Modify, DeployIfNotExists)
- Testing policy compliance and remediation workflows
- Implementing tagging strategies at scale
- Controlling resource deployment locations for compliance
- Automating policy definition and assignment via Infrastructure-as-Code
- Real-world policy testing with virtual machines

### How It Fits Into the Broader Solution

This project is part of a larger Azure architecture learning repository demonstrating enterprise governance patterns:

1. **Policy-as-Code**: Uses Bicep to define policies as code, enabling version control and reproducibility
2. **Compliance Testing**: Creates isolated environments to test policy behavior without affecting production
3. **Multi-RG Strategy**: Demonstrates different policy scopes and effects across multiple resource groups
4. **Remediation Automation**: Shows how to automatically remediate non-compliant resources (NSG creation and NIC association)

---

## System Requirements

### Operating System

- **Windows 10/11** (for running PowerShell scripts with full Azure CLI integration)
- **macOS/Linux** (with minor script modifications for PowerShell Core)

### Required Software and Tools

| Tool | Version | Purpose |
|------|---------|---------|
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) | Latest | Creating resources and managing policy assignments |
| [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell) | 5.1+ or PowerShell Core 7+ | Running deployment orchestration scripts |
| [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) | Latest | Validating Bicep templates (optional, included with Azure CLI) |
| [Git](https://git-scm.com/) | Latest | Version control (optional but recommended) |

### Azure CLI Extensions and Modules

No additional Azure CLI extensions are required for this project. All operations use standard Azure CLI commands for:

- Subscription and resource group management
- Policy definition and assignment
- Virtual machine deployment
- Network resource management

---

## Azure Resources

### Resource Groups Created

#### 1. **00002-tags-deployifnotexists-nsg**
- **Location**: West US (`westus`)
- **Purpose**: Test tagging policies and remediation through automated resource creation
- **Contains**:
  - Virtual Network with subnet (CIDR: 11.3.0.0/16)
  - Network Interface Card (NIC) for virtual machine
  - Windows Server 2022 virtual machine
  - Network Security Group (NSG) auto-created by DeployIfNotExists policy
  
- **Policies Applied**:
  - Enforce Tags - requires specified tag on all resources
  - DeployIfNotExists - auto-creates NSG if not present
  - Modify - auto-associates NSG with NIC

#### 2. **00002-deny-locations**
- **Location**: West US (`westus`)
- **Purpose**: Test location-based compliance and denial policies
- **Contains**: (Designated for testing Deny policies)
  
- **Policies Applied**:
  - Deny Location - rejects deployments in regions other than `westus` and `eastus`

### Deployed Azure Resources

| Resource Type | Resource Name | Resource Group | Purpose |
|---|---|---|---|
| Policy Definition | 00002-Enforce-tags | Subscription | Enforces mandatory tags on all resources |
| Policy Definition | 00002-Deploy-nsg-if-not-exists | Subscription | Creates NSG automatically if missing |
| Policy Definition | 00002-Modify-nic-to-add-nsg | Subscription | Associates NSG with network interfaces |
| Policy Definition | 00002-Deny-location | Subscription | Restricts deployments to allowed regions |
| Virtual Network | 00002-vnet | 00002-tags-deployifnotexists-nsg | Network infrastructure for VMs |
| Network Interface | vm-rg1-nic | 00002-tags-deployifnotexists-nsg | Primary network interface for VM |
| Virtual Machine | vm-rg1 | 00002-tags-deployifnotexists-nsg | Windows Server 2022 for testing |
| Network Security Group | 00002-nsg | 00002-tags-deployifnotexists-nsg | Auto-created by DeployIfNotExists policy |

---

## Roles and Permissions

### Required Azure Roles

To execute this project, your Azure user account or service principal must have the following roles assigned:

| Role | Scope | Purpose |
|------|-------|---------|
| **Contributor** | Subscription | Create/manage resource groups and all resources |
| **Resource Policy Contributor** | Subscription | Create and manage policy definitions and assignments |
| **User Access Administrator** | Subscription | Assign roles to remediation tasks and system-assigned identities |

### Alternative: Custom Role (Least-Privilege)

If your organization enforces least-privilege principles, create a custom role with the following permissions:

```json
{
  "properties": {
    "roleName": "00002_azure_policy_deployment",
    "description": "Deploy Azure Policies and remediate non-compliant resources",
    "assignableScopes": [
      "/subscriptions/{SUBSCRIPTION_ID}"
    ],
    "permissions": [
      {
        "actions": [
          "Microsoft.Resources/subscriptions/resourceGroups/write",
          "Microsoft.Resources/subscriptions/resourceGroups/read",
          "Microsoft.Authorization/policyDefinitions/write",
          "Microsoft.Authorization/policyDefinitions/read",
          "Microsoft.Authorization/policyAssignments/write",
          "Microsoft.Authorization/policyAssignments/read",
          "Microsoft.Authorization/roleAssignments/write",
          "Microsoft.Authorization/roleAssignments/read",
          "Microsoft.Compute/virtualMachines/write",
          "Microsoft.Compute/virtualMachines/read",
          "Microsoft.Network/virtualNetworks/write",
          "Microsoft.Network/virtualNetworks/read",
          "Microsoft.Network/networkInterfaces/write",
          "Microsoft.Network/networkInterfaces/read",
          "Microsoft.Network/networkSecurityGroups/write",
          "Microsoft.Network/networkSecurityGroups/read",
          "Microsoft.Deployments/deployments/write"
        ],
        "notActions": []
      }
    ]
  }
}
```

### Permission Scope

- **Subscription level**: Policy definition creation and assignment, role assignments for remediation
- **Resource group level**: Resource creation and management
- **Resource level**: Specific resource configuration and compliance tracking

---

## How to Run the Project

### Prerequisites

Before running the deployment, ensure:

1. ✅ All system requirements are installed and accessible from your terminal
2. ✅ You are authenticated with Azure CLI:
   ```powershell
   az login
   ```
3. ✅ The correct Azure subscription is selected:
   ```powershell
   az account show
   az account set --subscription "Your Subscription Name"
   ```
4. ✅ You have the required roles (Contributor, Resource Policy Contributor, User Access Administrator)

### Step 1: Prepare VM Administrator Password

The script requires a secure password for virtual machine access. You can provide it interactively or as a parameter.

**Interactive (prompt during execution):**
```powershell
# Password will be requested during script execution
.\main.ps1
```

**Via Parameter (secure input):**
```powershell
$password = Read-Host "Enter VM password" -AsSecureString
.\main.ps1 -pPassword $password
```

### Step 2: Run the Main Deployment Script

Navigate to the project directory and execute the deployment script:

```powershell
cd .\00002-PROJECT-AZURE-POLCY-REMEDIATION-TASKS\

.\main.ps1 `
    -ProjectTagName "Environment" `
    -ProjectTagValue "QA" `
    -pSubscriptionName "Your Subscription Name"
```

Or with password parameter:

```powershell
$password = Read-Host "Enter VM password" -AsSecureString

.\main.ps1 `
    -ProjectTagName "Environment" `
    -ProjectTagValue "QA" `
    -pPassword $password `
    -pSubscriptionName "Your Subscription Name"
```

### Required Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `-ProjectTagName` | String | ✅ Yes | — | Tag name to enforce on all resources (e.g., `Environment`, `Project`, `Owner`). |
| `-ProjectTagValue` | String | ✅ Yes | — | Tag value to enforce (e.g., `QA`, `Production`, `Development`). |
| `-pPassword` | SecureString | ❌ No | Interactive | VM administrator password (must be 12+ characters, include uppercase, lowercase, digits, special chars). If not provided, script will prompt interactively. |
| `-pSubscriptionName` | String | ❌ No | `Suscripción de Plataformas de MSDN` | Name of the Azure subscription to deploy to. |

### Step 3: Monitor Policy Application

After deployment completes, verify policy compliance:

```powershell
# Check policy assignments
az policy assignment list --subscription "{SUBSCRIPTION_ID}" --query "[].{name:name, scope:scope, policyDefinitionId:policyDefinitionId}"

# Check policy compliance
az policy state summarize --subscription "{SUBSCRIPTION_ID}" --query "results.resourceDetails[].{resourceId:id, complianceState:complianceState}"
```

### Step 4: Test Policy Enforcement

Try deploying a resource without the required tag to see the policy in action:

```powershell
# This will fail due to enforce tags policy
az resource create --id "/subscriptions/{SUB_ID}/resourceGroups/00002-tags-deployifnotexists-nsg/providers/Microsoft.Compute/virtualMachines/test-vm-untagged" `
    --properties @{} `
    2>&1
```

### Example Deployment Command

```powershell
# Full example with all parameters
$password = Read-Host "Enter secure password for VMs" -AsSecureString

.\main.ps1 `
    -ProjectTagName "Environment" `
    -ProjectTagValue "Production" `
    -pPassword $password `
    -pSubscriptionName "My Production Subscription"
```

---

## Project Structure

```
00002-PROJECT-AZURE-POLCY-REMEDIATION-TASKS/
├── main.ps1                          # Main deployment orchestration script
├── README.md                          # This file
├── .policies/                         # Azure Policy definitions
│   ├── azure-policy-modify-enforce-tags.bicep
│   ├── azure-policy-deny-location.bicep
│   ├── azure-policy-deployifnotexists.bicep
│   └── azure-policy-modify-nic-to-add-nsg.bicep
└── .artifacts/                       # Supporting files (if applicable)
```

---

## Azure Policies Explained

### 1. Enforce Tags Policy (`azure-policy-modify-enforce-tags.bicep`)

**Type**: Modify  
**Scope**: All resource groups  
**Effect**: Automatically adds the specified tag to all resources

- Adds tag key from `pTagName` parameter with value from `pTagValue`
- Applied at creation time (modification effect)
- Ensures compliance without blocking deployments

**Example**: Tag key `Environment`, value `QA` is added to all resources

### 2. Deny Location Policy (`azure-policy-deny-location.bicep`)

**Type**: Deny  
**Scope**: 00002-deny-locations RG  
**Effect**: Blocks resource deployments in restricted locations

- Only allows deployments in `westus` or `eastus` regions
- Prevents accidental deployments in disallowed regions
- Applied at creation time

**Example**: Attempting to deploy in `eastasia` region will be rejected

### 3. Deploy if Not Exists Policy (`azure-policy-deployifnotexists.bicep`)

**Type**: DeployIfNotExists  
**Scope**: 00002-tags-deployifnotexists-nsg RG  
**Effect**: Automatically creates NSG if one doesn't exist

- Checks for Network Security Group
- Deploys NSG automatically if missing
- Uses system-assigned managed identity for deployment

**Example**: NSG created automatically when VM is deployed without one

### 4. Modify NIC Policy (`azure-policy-modify-nic-to-add-nsg.bicep`)

**Type**: Modify  
**Scope**: 00002-tags-deployifnotexists-nsg RG  
**Effect**: Associates NSG with Network Interface Cards

- Automatically associates the 00002-nsg with all NICs
- Ensures network security is applied
- Applied at creation time

**Example**: VM NIC is automatically linked to the NSG

---

## Troubleshooting

### Issue: PowerShell Script Execution Policy

**Error**: `cannot be loaded because running scripts is disabled on this system`

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: Insufficient Permissions

**Error**: `AuthorizationFailed: The client does not have authorization to perform action 'Microsoft.Authorization/policyAssignments/write'`

**Solution**:
1. Verify you have Resource Policy Contributor role:
   ```powershell
   az role assignment list --include-inherited
   ```
2. Request the necessary role from your Azure administrator

### Issue: Policy Conflicts

**Error**: `Policy conflict detected` or `DeploymentFailed`

**Solution**:
1. Check existing policies in your subscription:
   ```powershell
   az policy definition list --query "[].{name:name, id:id}"
   ```
2. Remove conflicting policies or adjust parameter values

### Issue: VM Password Requirements Not Met

**Error**: `Password does not meet complexity requirements`

**Solution**: Password must contain:
- At least 12 characters
- Uppercase letters (A-Z)
- Lowercase letters (a-z)
- Numbers (0-9)
- Special characters (!@#$%^&*)

Example: `P@ssw0rd2025!`

### Issue: Deployment Timeout

**Error**: `Deployment timed out after 2 hours`

**Solution**:
1. Check Azure CLI logs:
   ```powershell
   az deployment sub list --query "[].{name:name, provisioningState:properties.provisioningState}"
   ```
2. Resume with specific deployment name or retry with increased timeout

---

## Learning Resources

This project demonstrates key Azure governance and policy concepts:

- **Azure Policy Mechanisms**: Deny, Modify, DeployIfNotExists, Audit, AuditIfNotExists
- **Compliance Enforcement**: Automated remediation and policy assignment
- **Infrastructure as Code**: Bicep templates for policy definition
- **Network Security**: NSG automation and network interface management
- **Multi-RG Strategies**: Different policies for different compliance requirements
- **PowerShell Automation**: Complex orchestration and error handling

For more information:

- [Microsoft Learn - Azure Policy Overview](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [Microsoft Learn - Policy Effects](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effects)
- [Microsoft Learn - Remediation](https://learn.microsoft.com/en-us/azure/governance/policy/how-to/remediate-resources)
- [Bicep Policy Examples](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)

---

## Cleanup

To remove all resources created by this project:

```powershell
# Delete resource groups (this removes all contained resources)
az group delete --name "00002-tags-deployifnotexists-nsg" --yes --no-wait
az group delete --name "00002-deny-locations" --yes --no-wait

# Delete policy assignments
az policy assignment delete --name "00002-Enforce-tags"
az policy assignment delete --name "00002-Deploy-nsg-if-not-exists"
az policy assignment delete --name "00002-Modify-nic-to-add-nsg"
az policy assignment delete --name "00002-Deny-location"

# Delete policy definitions
az policy definition delete --name "00002-Enforce-tags"
az policy definition delete --name "00002-Deploy-nsg-if-not-exists"
az policy definition delete --name "00002-Modify-nic-to-add-nsg"
az policy definition delete --name "00002-Deny-location"
```

## Credits

- **Author**: Jesus Lopez Mesia
- **LinkedIn**: [linkedin.com/in/susejzepol/](https://www.linkedin.com/in/susejzepol/)
- **Created**: December 6, 2025
- **Last Modified**: January 20, 2026

This project supports learning and hands-on practice for the [AZ-305](https://learn.microsoft.com/en-us/credentials/certifications/exams/az-305/) and [AZ-104](https://learn.microsoft.com/en-us/credentials/certifications/azure-administrator/) Azure certification exams, as well as to explore various Azure technologies.
