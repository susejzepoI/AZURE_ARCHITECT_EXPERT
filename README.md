# Azure Architect Expert

A comprehensive repository of hands-on projects demonstrating enterprise Azure patterns, governance, and Infrastructure-as-Code (IaC) implementation.

---

## Repository Overview

### What This Repository Contains

This repository is a curated collection of mini-projects designed to explore, test, and demonstrate various Azure deployment patterns and services. Each project provides:

- **Production-ready Infrastructure-as-Code** using Bicep and Azure CLI
- **Real-world governance patterns** including policy enforcement and compliance
- **Hands-on learning resources** for Azure certification exam preparation
- **Reusable templates and scripts** for enterprise Azure deployments

### Purpose

This repository serves as a learning and reference resource for:

- Understanding Azure service capabilities and integration patterns
- Implementing Infrastructure-as-Code best practices with Bicep
- Testing policy enforcement and remediation workflows
- Preparing for [AZ-305](https://learn.microsoft.com/en-us/credentials/certifications/exams/az-305/) and [AZ-104](https://learn.microsoft.com/en-us/credentials/certifications/azure-administrator/) Azure certification exams
- Exploring enterprise Azure governance and compliance strategies

---

## Repository Structure

```
AZURE_ARCHITECT_EXPERT/
├── 00001-PROJECT-HELLO-WORLD-AZURE-CONTAINER-INSTANCE/
│   ├── main.ps1                      # Deployment orchestration script
│   ├── README.md                      # Project-specific documentation
│   └── My-Hello-world-api/           # ASP.NET Core 8.0 API application
│       └── My_Hello_World_Api/
│           ├── Program.cs
│           ├── Dockerfile
│           ├── My_Hello_World_Api.csproj
│           └── Properties/
│
├── 00002-PROJECT-AZURE-POLCY-REMEDIATION-TASKS/
│   ├── main.ps1                      # Deployment orchestration script
│   ├── README.md                      # Project-specific documentation
│   └── .policies/                    # Azure Policy Bicep definitions
│       ├── azure-policy-modify-enforce-tags.bicep
│       ├── azure-policy-deny-location.bicep
│       ├── azure-policy-deployifnotexists.bicep
│       └── azure-policy-modify-nic-to-add-nsg.bicep
│
├── infra/                            # Shared infrastructure templates
│   ├── azure_cli/                    # Reusable Azure CLI scripts
│   └── bicep/                        # Reusable Bicep templates
│       ├── 01.- resource-group/
│       ├── 02.- network/
│       ├── 03.- virtual machine/
│       ├── 04.- Azure Container Registry/
│       └── 05.- Azure Container Instance/
│
├── AZURE_ARCHITECT_EXPERT.sln        # Visual Studio solution file
├── README.md                          # This file
└── .github/
    └── workflows/                    # GitHub Actions CI/CD workflows
```

**Note**: Each sub-project contains its own detailed README.md with specific instructions, requirements, and architecture details.

---

## Available Projects

### 00001 - Hello World API on Azure Container Instance

Demonstrates containerized application deployment using Azure Container Instance and Azure Container Registry.

**Key Technologies**: ASP.NET Core 8.0, Docker, Azure Container Registry, Azure Container Instance, Bicep

**Topics Covered**: Container orchestration, multi-stage Docker builds, IaC patterns, environment-aware configuration

[View Project Details](./00001-PROJECT-HELLO-WORLD-AZURE-CONTAINER-INSTANCE/README.md)

### 00002 - Azure Policy and Remediation Tasks

Demonstrates advanced Azure governance through policy implementation, enforcement, and automated remediation.

**Key Technologies**: Azure Policy, Bicep, Network Security Groups, Virtual Machines, Azure PowerShell

**Topics Covered**: Policy-as-Code, compliance enforcement, automated remediation, multi-RG strategies, tagging policies

[View Project Details](./00002-PROJECT-AZURE-POLCY-REMEDIATION-TASKS/README.md)

### Additional Projects

More projects coming soon exploring additional Azure services and patterns.

---

## System Requirements

### Global Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) | Latest | Azure resource provisioning and management |
| [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell) | 5.1+ or Core 7+ | Script orchestration and deployment automation |
| [Git](https://git-scm.com/) | Latest | Repository version control |
| [Visual Studio Code](https://code.visualstudio.com/) | Latest | Code editor with Bicep extension (optional) |

### Project-Specific Requirements

Each sub-project may have additional tool requirements. Refer to the specific project's README for details:

- **00001**: .NET 8 SDK, Docker Desktop
- **00002**: None (uses only Azure CLI and PowerShell)

### Azure Permissions

**Minimum Required Roles** (varies by project):
- **Contributor** - Create and manage Azure resources
- **Resource Policy Contributor** - Create and manage policies (project 00002)
- **User Access Administrator** - Manage role assignments (project 00002)

See individual project README files for specific permission requirements.

---

## Getting Started

### Prerequisites

1. ✅ **Clone the repository**:
   ```powershell
   git clone https://github.com/susejzepoI/AZURE_ARCHITECT_EXPERT.git
   cd AZURE_ARCHITECT_EXPERT
   ```

2. ✅ **Install Azure CLI**:
   ```powershell
   # Windows
   choco install azure-cli
   
   # Or download from https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
   ```

3. ✅ **Authenticate with Azure**:
   ```powershell
   az login
   az account show
   az account set --subscription "Your Subscription Name"
   ```

4. ✅ **Verify permissions**:
   ```powershell
   az role assignment list --include-inherited --query "[].{role:roleDefinitionName, scope:scope}"
   ```

### Running a Project

Each project is self-contained with its own deployment script and detailed README:

```powershell
# Navigate to the project directory
cd .\00001-PROJECT-HELLO-WORLD-AZURE-CONTAINER-INSTANCE\

# Review project-specific requirements
cat .\README.md

# Execute the deployment script
.\main.ps1 -ImageName "hello-world-api:v1.0" -Environment "production"
```

**Important**: PowerShell scripts must be executed from within their project directory.

### Project Execution Examples

#### Project 00001 - Container Instance

```powershell
cd .\00001-PROJECT-HELLO-WORLD-AZURE-CONTAINER-INSTANCE\

.\main.ps1 `
    -ImageName "hello-world-api:v1.0" `
    -Environment "Development"
```

#### Project 00002 - Azure Policy

```powershell
cd .\00002-PROJECT-AZURE-POLCY-REMEDIATION-TASKS\

$password = Read-Host "Enter VM password" -AsSecureString

.\main.ps1 `
    -ProjectTagName "Environment" `
    -ProjectTagValue "QA" `
    -pPassword $password
```

---

## Infrastructure-as-Code

This repository demonstrates IaC best practices using **Bicep**, Microsoft's domain-specific language for Azure Resource Manager (ARM) templates.

### Shared Templates

Reusable Bicep templates are located in the `infra/bicep/` directory:

- **Resource Groups**: Create and manage Azure resource groups
- **Network Infrastructure**: Virtual Networks, Subnets, Network Interface Cards
- **Virtual Machines**: Windows and Linux VM deployments
- **Container Registry**: Azure Container Registry setup
- **Container Instance**: Azure Container Instance deployment

These templates are leveraged by all projects to ensure consistency and reduce duplication.

### Using Bicep Templates

```powershell
# Validate a Bicep template
bicep build ./infra/bicep/01.- resource-group/resource-group.bicep

# Deploy using Azure CLI
az deployment group create `
    --resource-group "MyResourceGroup" `
    --template-file "./infra/bicep/02.- network/vnet-1-subnet-1.bicep" `
    --parameters @params.json
```

---

## GitHub Actions (CI/CD)

GitHub Actions workflows are available for automated deployments. To use them:

1. **Configure Federated Identity Credential**:
   - [Azure Documentation - OIDC with GitHub](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)

2. **Configure GitHub Secrets**:
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`

3. **Trigger Workflows**:
   - Workflows are located in `.github/workflows/`
   - Refer to workflow files for trigger conditions and parameters

---

## Project Cleanup

To remove resources created by any project:

```powershell
# Navigate to project directory
cd .\00002-PROJECT-AZURE-POLCY-REMEDIATION-TASKS\

# Review the Cleanup section in the project README
cat .\README.md | Select-String -Pattern "Cleanup" -A 20

# Execute cleanup commands provided in the README
```

---

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:
- Code follows project conventions
- README files are updated with new information
- Bicep templates pass validation (`bicep build`)
- PowerShell scripts follow naming conventions

---

## Troubleshooting

### Common Issues

#### Azure CLI Not Found
```powershell
az --version
# If not installed, download from: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
```

#### Authentication Failures
```powershell
az logout
az login --use-device-code
```

#### PowerShell Execution Policy
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

For project-specific troubleshooting, refer to the individual project README files.

---

## Learning Resources

### Azure Services
- [Microsoft Learn - Azure](https://learn.microsoft.com/en-us/azure/)
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/)

### Certification Preparation
- [AZ-305: Designing Microsoft Azure Infrastructure Solutions](https://learn.microsoft.com/en-us/credentials/certifications/exams/az-305/)
- [AZ-104: Microsoft Azure Administrator](https://learn.microsoft.com/en-us/credentials/certifications/azure-administrator/)

### Infrastructure as Code
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [ARM Template Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/)

### Azure Policy
- [Azure Policy Overview](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [Policy Effects](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effects)

---

## License

This repository is provided as-is for educational purposes.

---

## Credits

- **Author**: Jesus Lopez Mesia
- **LinkedIn**: [linkedin.com/in/susejzepol/](https://www.linkedin.com/in/susejzepol/)
- **Repository**: [GitHub - AZURE_ARCHITECT_EXPERT](https://github.com/susejzepoI/AZURE_ARCHITECT_EXPERT)

This repository supports learning and hands-on practice for Azure certification exams and enterprise Azure architecture patterns.

---

**Last Updated**: January 22, 2026