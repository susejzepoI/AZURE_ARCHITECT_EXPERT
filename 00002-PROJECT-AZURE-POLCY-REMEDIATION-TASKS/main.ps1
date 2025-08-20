[CmdletBinding()]
param (
    [Parameter()]
    [string]$pSubscriptionName = 'Suscripción de Plataformas de MSDN',
    [Parameter()]
    [string]$rg1 = '00002-project-enforcing-location-effect-deny',
    [Parameter()]
    [string]$rg2 = '00002-project-eforcing-tag-effect-modify'

)

#JLopez-20250508: Deploying the resource group using a bicep template.
az deployment sub create `
    --name '00002-Deployment-1' `
    --location 'eastus' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$rg1 pLocation='eastus' `
    --subscription $pSubscriptionName

az deployment sub create `
    --name '00002-Deployment-2' `
    --location 'eastus' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$rg2 pLocation='eastus' `
    --subscription $pSubscriptionName

#JLopez-20250819: Deploying the network interface and the virtual network.
az deployment group create `
    --name '00002-Deployment-2' `
    --parameters pAddressPrefix='11.0.0.0/16' pSubnetPrefix='11.0.0.0/24' `
    --resource-group $rg1 `
    --template-file '../infra/bicep/02.- network/vnet-1-subnet-1-nic.bicep' 