[CmdletBinding()]
param (
    [Parameter()]
    [string]$pSubscriptionName = 'Suscripción de Plataformas de MSDN'
)

#JLopez-20250508: Deploying the resource group using a bicep template
az deployment sub create `
    --name '00002-Deployment' `
    --location 'eastus' `
    --template-file './infra/bicep/resource-group.bicep' `
    --parameters pName='00002-project-eforcing-tag-effect-modify' pLocation='eastus' `
    --subscription $pSubscriptionName

az deployment sub create `
    --name '00002-Deployment' `
    --location 'eastus' `
    --template-file './infra/bicep/resource-group.bicep' `
    --parameters pName='00002-project-enforcing-location-effect-deny' pLocation='eastus' `
    --subscription $pSubscriptionName