#Author:            Jesus Lopez Mesia
#Linkedin:          https://www.linkedin.com/in/susejzepol/
#Created date:      06-12-2025
#Modified date:     06-16-2025

[cmdletBinding()]
param(
    [parameter(HelpMessage='Name of the subscription to use in the script.')]
    [string]$SubscriptionName      = 'Suscripción de Plataformas de MSDN',
    [parameter(Mandatory=$true)]
    [string]$ProjectPrefix         = '00001'   
)

#JLopez-20250823: Defining the resource groups to be created.
$pSubscriptionName              = $SubscriptionName
$pProjectPrefix                 = $ProjectPrefix
$pResourceGroupName             = "$($pProjectPrefix)-RG1-ACI"

Write-Host "Starting deployment for project: $pProjectPrefix" -BackgroundColor Green
Write-Host "Using subscription: $pSubscriptionName" -BackgroundColor Green

Write-Host "Deploying the resource group: $pResourceGroupName" -BackgroundColor Green
$DeploymentName = "$($ProjectPrefix)-rg1-Deployment-1"
az deployment sub create `
    --name $DeploymentName `
    --location 'chilecentral' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$pResourceGroupName pLocation='chilecentral' `
    --subscription $pSubscriptionName