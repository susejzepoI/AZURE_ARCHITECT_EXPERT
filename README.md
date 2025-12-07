## What is repository about?
This repository contains a collection of mini-projects used to explore and test various Azure deployments using Bicep and Azure CLI. Its main purpose is to help me understand the differences between Azure services, as well as how to manage and implement them using CLI commands.
Additionally, this repository serves as a practice environment for preparing for the [AZ-305](https://learn.microsoft.com/en-us/credentials/certifications/exams/az-305/) and [AZ-104](https://learn.microsoft.com/en-us/credentials/certifications/azure-administrator/?practice-assessment-type=certification) certification exams.

## Project structure
Below, I shown the structure of the current repository:

```md
.
├── AZURE_ARCHITECT_EXPERT
│   ├── .github             # GitHub Actions
│   │     └── workflows 
│   ├── 00001-Project       # Deploying azure container instances
│   │     ├── main.ps1      # Main powershell that deploys all the resources
│   │     └── readme.md     # File with all the information to use project
│   ├── 00002-Project       # Deploying azure policies
│   └── 00003-Project       # Deploying a CosmosDB
└── infra
    ├── azure CLI           # Reutilizable azure cli templates
    └── bicep               # Reutilizable bicep templates
```

**NOTE:** For additional details on each sub-project, please review the README file located in each folder.

## Getting started
#### 1. Prerequisits
* Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
* Visual Studio Code with the bicep extensión (Optional).
* Roles and permissions to run each project: Projects might have different permission requirements dependeing on the resources deployed, but in general, you need at least the *Contributor* role at the subscription or management group level where you want to deploy resources.

#### 2. Use the github actions
To reuse the GitHub actions in this repository, you must configure a federated indentity credential on a Microsoft Entra application or user-assigned identity, grant it the necessary permissions to deploy resources, and configure your github secrets correctly. For more information, see this [Azure documentation](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect#prerequisites).

#### 3. Run each scripts
To run any of these projects, first navigate into the corresponding sub-project folder and then execute the main PowerShell file. An example is provided below using one of the projects in this repository:

```sh
cd .\00002-PROJECT-AZURE-POLCY-REMEDIATION-TASKS\

.\main.ps1 `
            -ProjectTagName "Environment" `
            -ProjectTagValue "QA" `
            -pPassword $secure
```
**IMPORTANT:** The main PowerShell scripts currently do not run unless you execute them from within the sub-project folder, as shown in the example above.

## Contributing
Contributions are welcome!. Just send a PR.

## Credits
This repository was initially created by [Jesus Lopez](https://www.linkedin.com/in/susejzepol/). Its purpose is to support learning and hands-on practice for the [AZ-305](https://learn.microsoft.com/en-us/credentials/certifications/exams/az-305/) and [AZ-104](https://learn.microsoft.com/en-us/credentials/certifications/azure-administrator/?practice-assessment-type=certification) certification exams, as well as to explore various Azure technologies.