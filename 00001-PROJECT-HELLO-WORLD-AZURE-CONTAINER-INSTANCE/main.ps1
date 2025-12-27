#Author:            Jesus Lopez Mesia
#Linkedin:          https://www.linkedin.com/in/susejzepol/
#Created date:      06-12-2025
#Modified date:     26-12-2025

[cmdletBinding()]
param(
    [parameter(HelpMessage='Name of the subscription to use in the script.')]
    [string]$SubscriptionName      = 'Suscripción de Plataformas de MSDN',
    [parameter(Mandatory=$true)]
    [string]$ProjectPrefix         = '00001'   
)

#JLopez-20251222: Defining the resource groups to be created.
$pSubscriptionName              = $SubscriptionName
$pProjectPrefix                 = $ProjectPrefix
$pResourceGroupName             = "$($pProjectPrefix)-RG1-ACI"
#JLopez-20251222: This resource group will contain shared resources for all subprojects.
$pResourceGroupInfraName        = "$($pProjectPrefix)-RG-INFRA"

Write-Host "Starting deployment for project: $pProjectPrefix" -BackgroundColor Green
Write-Host "Using subscription: $pSubscriptionName" -BackgroundColor Green

Write-Host "Deploying the resource group: $pResourceGroupInfraName" -BackgroundColor Green
az deployment sub create `
    --name 'Deployment-rg-infra' `
    --location 'brazilsouth' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$pResourceGroupInfraName pLocation='brazilsouth' `
    --subscription $pSubscriptionName

Write-Host "Deploying the resource group: $pResourceGroupName" -BackgroundColor Green
$DeploymentName = "$($ProjectPrefix)-rg1-Deployment-1"
az deployment sub create `
    --name $DeploymentName `
    --location 'chilecentral' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$pResourceGroupName pLocation='chilecentral' `
    --subscription $pSubscriptionName

$MyNameACR = $(
        az acr list `
            --resource-group $rg `
            --query "[?contains(name, 'myacr')].name" `
            -o tsv
)

Write-Host "Deploying the Azure Container Registry" -BackgroundColor Green
az deployment group create `
    --name "$($ProjectPrefix)-acr-infra-deployment-1" `
    --resource-group $pResourceGroupInfraName `
    --template-file '../infra/bicep/04.- Azure Container Registry/deploy-my-acr.bicep' `
    --parameters acrName=$MyNameACR `
    --subscription $pSubscriptionName --debug