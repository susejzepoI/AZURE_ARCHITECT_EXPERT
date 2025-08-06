[CmdletBinding()]
param (
    [Parameter()]
    [string]$pSubscriptionName = 'Suscripción de Plataformas de MSDN'
)

#JLopez-2025-05-08: Deploying the resource group using a bicep template
az deployment sub create `
    --name '00002-Deployment' `
    --location 'eastus' `
    --template-file './infra/bicep/resource-group.bicep' `
    --parameters pName='00002-project-rg' pLocation='eastus' `
    --subscription $pSubscriptionName