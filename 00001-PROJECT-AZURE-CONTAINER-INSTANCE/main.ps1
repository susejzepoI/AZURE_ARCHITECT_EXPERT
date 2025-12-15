#Author:            Jesus Lopez Mesia
#Linkedin:          https://www.linkedin.com/in/susejzepol/
#Created date:      06-12-2025
#Modified date:     06-15-2025

[cmdletBinding()]
param(
    [parameter(HelpMessage='Name of the subscription to use in the script.')]
    [string]$SubscriptionName      = 'Suscripción de Plataformas de MSDN',
    [parameter(Mandatory=$true)]
    [string]$ProjectPrefix         = '00001'   
)

#JLopez-20250823: Defining the resource groups to be created.
$pProjectPrefix                 = $ProjectPrefix
$pResourceGroupName             = "$($pProjectPrefix)-RG1-ACI"
Write-Host "Starting deployment for project: $pProjectPrefix" -BackgroundColor Green
Write-Host "Deploying the resource group: $pResourceGroupName" -BackgroundColor Green


az deployment sub create `
    --name '$ProjectPrefix-rg1-Deployment-1' `
    --location 'chilecentral' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$rg1 pLocation='chilecentral' `
    --subscription $pSubscriptionName