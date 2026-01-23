# 00001 - Project: Hello World API on Azure Container Instance

## Project Overview

### What the Project Does

This project demonstrates a containerized ASP.NET Core 8.0 API deployed to **Azure Container Instance (ACI)** using a modern Infrastructure-as-Code (IaC) approach. The solution includes:

- A minimal ASP.NET Core Web API with Swagger/OpenAPI documentation
- Docker containerization with multi-stage builds for optimized image size
- Azure Container Registry (ACR) for image storage and management
- Infrastructure deployment using Bicep templates
- Automated end-to-end deployment orchestrated via PowerShell

### Problem It Solves

This project serves as a foundational learning resource for:

- Understanding containerization workflows in Azure
- Implementing Infrastructure-as-Code patterns with Bicep
- Automating container image building, pushing, and deployment
- Setting up shared infrastructure (ACR) across multiple projects
- Demonstrating environment-aware application configuration

### How It Fits Into the Broader Solution

This project is part of a larger Azure architecture learning repository. It demonstrates:

1. **Multi-project resource sharing**: Uses a shared infrastructure resource group (`RG-INFRA`) for the Azure Container Registry
2. **Bicep templates reusability**: Leverages centralized IaC templates for resource group creation and ACI deployment
3. **Scalability pattern**: Can be extended to deploy multiple containerized applications using the same infrastructure and PowerShell orchestration framework

---

## System Requirements

### Operating System

- **Windows 10/11** (for running PowerShell scripts with full Azure CLI integration)
- **macOS/Linux** (with minor script modifications for PowerShell Core)

### Required Software and Tools

| Tool | Version | Purpose |
|------|---------|---------|
| [.NET SDK](https://dotnet.microsoft.com/en-us/download) | 8.0 or later | Building and publishing the ASP.NET Core API |
| [Docker Desktop](https://www.docker.com/products/docker-desktop) | Latest | Building and testing container images locally |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) | Latest | Deploying resources and managing ACR |
| [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell) | 5.1+ or PowerShell Core 7+ | Running deployment orchestration scripts |
| [Git](https://git-scm.com/) | Latest | Version control (optional but recommended) |

### Azure CLI Extensions and Modules

No additional Azure CLI extensions are required for this project. The deployment uses standard Azure CLI commands for:

- Resource group creation
- Container Registry operations
- Container Instance deployment

---

## Azure Resources

### Resource Groups Created

#### 1. **RG-INFRA**
- **Location**: Brazil South (`brazilsouth`)
- **Purpose**: Shared infrastructure for all subprojects
- **Contains**:
  - Azure Container Registry (ACR) for storing container images
  - Used across multiple projects to centralize image management

#### 2. **00001-RG1-ACI**
- **Location**: Chile Central (`chilecentral`)
- **Purpose**: Project-specific resources for the Hello World API
- **Contains**:
  - Azure Container Instance running the containerized API
  - Manages the deployed application and its execution environment

### Deployed Azure Resources

| Resource Type | Resource Name | Resource Group | Purpose |
|---|---|---|---|
| Azure Container Registry | Auto-generated | `RG-INFRA` | Stores Docker images used by all projects |
| Azure Container Instance | Auto-generated | `00001-RG1-ACI` | Runs the Hello World API container |

---

## Roles and Permissions

### Required Azure Roles

To execute this project, your Azure user account or service principal must have the following roles assigned:

| Role | Scope | Purpose |
|------|-------|---------|
| **Contributor** | Subscription | Create and manage resource groups and all Azure resources |
| **AcrPush** | ACR (RG-INFRA) | Push container images to Azure Container Registry |
| **AcrPull** | ACR (RG-INFRA) | Pull images from ACR (required for ACI to access images) |

### Alternative: Custom Role

If your organization enforces least-privilege principles, create a custom role with the following permissions:

```json
{
  "properties": {
    "roleName": "00001-Hello-World-ACI-Deployment",
    "description": "Deploy Hello World API to Azure Container Instance",
    "assignableScopes": [
      "/subscriptions/{SUBSCRIPTION_ID}"
    ],
    "permissions": [
      {
        "actions": [
          "Microsoft.Resources/subscriptions/resourceGroups/write",
          "Microsoft.Resources/subscriptions/resourceGroups/read",
          "Microsoft.ContainerRegistry/registries/write",
          "Microsoft.ContainerRegistry/registries/read",
          "Microsoft.ContainerRegistry/registries/listCredentials/action",
          "Microsoft.ContainerRegistry/registries/push/write",
          "Microsoft.ContainerRegistry/registries/pull/read",
          "Microsoft.ContainerInstance/containerGroups/write",
          "Microsoft.ContainerInstance/containerGroups/read",
          "Microsoft.Deployments/deployments/write"
        ],
        "notActions": []
      }
    ]
  }
}
```

### Permission Scope

- **Subscription level**: Resource group creation and deployments
- **Resource group level**: Resource creation and management within each RG
- **ACR level**: Image push/pull operations

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

### Step 1: Run the Main Deployment Script

Navigate to the project directory and execute the deployment script:

```powershell
cd .\00001-PROJECT-HELLO-WORLD-AZURE-CONTAINER-INSTANCE\

.\main.ps1 `
    -ImageName "hello-world-api:v1.0" `
    -SubscriptionName "Your Subscription Name" `
    -Environment "Development"
```

### Step 2: Build the Docker Image Locally (Optional)

To verify the application runs correctly before deploying to Azure:

```powershell
cd ./My-Hello-world-api/My_Hello_World_Api

docker build -t my-hello-world-api:latest .
docker run -p 8080:8080 -e APP_ENVIRONMENT="Local" my-hello-world-api:latest

# Test the API
curl http://localhost:8080
curl http://localhost:8080/Environment_information
```

### Required Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `-SubscriptionName` | String | ❌ No | `Suscripción de Plataformas de MSDN` | Name of the Azure subscription to deploy to. |
| `-ImageName` | String | ✅ Yes | — | Docker image name and tag (e.g., `hello-world-api:v1.0`). |
| `-Environment` | String | ❌ No | `Development` | Environment name passed to the container as `APP_ENVIRONMENT` variable. Options: `Development`, `Staging`, `Production`. |

### Step 3: Verify Deployment

After the script completes successfully, it will output:

```
API Information
Container IP: <Public-IP-Address>
Endpoint: http://<Public-IP-Address>:8080
```

Test the deployed API:

```powershell
$containerIP = "<Public-IP-Address>"
Invoke-WebRequest -Uri "http://$containerIP:8080"
Invoke-WebRequest -Uri "http://$containerIP:8080/Environment_information" | ConvertTo-Json
```

### Example Deployment Command

```powershell
# Full example with custom values
.\main.ps1 `
    -SubscriptionName "My Production Subscription" `
    -ImageName "hello-world-api:1.0.0" `
    -Environment "Production"
```

---

## Project Structure

```
00001-PROJECT-HELLO-WORLD-AZURE-CONTAINER-INSTANCE/
├── main.ps1                          # Main deployment orchestration script
├── README.md                          # This file
└── My-Hello-world-api/
    └── My_Hello_World_Api/
        ├── Program.cs                 # ASP.NET Core application entry point
        ├── My_Hello_World_Api.csproj  # .NET project configuration
        ├── Dockerfile                 # Multi-stage Docker build
        ├── appsettings.json           # Default application settings
        ├── appsettings.Development.json
        ├── Properties/
        │   └── launchSettings.json    # Local run configurations
        └── bin/obj/                   # Build output directories
```

---

## API Endpoints

The deployed API exposes the following endpoints:

### GET `/`

Returns a simple greeting message with the environment variable.

**Response:**
```
Hello world from my Azure Container Instance (Development)!.
```

### GET `/Environment_information`

Returns JSON object with service information and current UTC time.

**Response:**
```json
{
  "ServiceCollection": "Hello World API",
  "appEnv": "Development",
  "timeUTC": "2026-01-22T14:30:45.1234567Z"
}
```

---

## Troubleshooting

### Issue: PowerShell Script Execution Policy

**Error**: `cannot be loaded because running scripts is disabled on this system`

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: Docker Build Fails

**Error**: `failed to build Docker image`

**Solution**:
1. Ensure Docker Desktop is running
2. Verify .NET 8 SDK is installed: `dotnet --version`
3. Rebuild the project: `dotnet clean && dotnet build`

### Issue: Azure CLI Authentication Fails

**Error**: `ERROR: Microsoft.Common.Core : Unexpected service error`

**Solution**:
```powershell
az logout
az login --use-device-code
```

### Issue: Container IP Not Accessible

**Error**: `Unable to connect to container public IP`

**Solution**:
1. Verify the ACI is running:
   ```powershell
   az container show --resource-group "{ProjectPrefix}-RG1-ACI" --name "helloworld"
   ```
2. Check logs:
   ```powershell
   az container logs --resource-group "{ProjectPrefix}-RG1-ACI" --name "helloworld"
   ```

---

## Learning Resources

This project demonstrates key Azure and containerization concepts:

- **Docker Best Practices**: Multi-stage builds for optimized image size
- **Infrastructure as Code**: Bicep templates for repeatable, version-controlled deployments
- **Azure Container Registry**: Centralized image management across projects
- **Azure Container Instance**: Quick container deployment without managing clusters
- **PowerShell Automation**: End-to-end deployment orchestration

For more information:
- [Microsoft Learn - Azure Container Instance](https://learn.microsoft.com/en-us/azure/container-instances/)
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

---

## Credits

- **Author**: Jesus Lopez Mesia
- **LinkedIn**: [linkedin.com/in/susejzepol/](https://www.linkedin.com/in/susejzepol/)
- **Created**: December 6, 2025
- **Last Modified**: January 20, 2026

This project supports learning for [AZ-305](https://learn.microsoft.com/en-us/credentials/certifications/exams/az-305/) and [AZ-104](https://learn.microsoft.com/en-us/credentials/certifications/azure-administrator/) Azure certification exams.

---

## License

Refer to the root repository for licensing information.


