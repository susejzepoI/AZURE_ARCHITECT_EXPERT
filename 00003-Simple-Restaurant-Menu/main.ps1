#Author:            Jesus Lopez Mesia
#Linkedin:          https://www.linkedin.com/in/susejzepol/
#Created date:      13-08-2026
#Modified date:     13-08-2026

[CmdletBinding()]
param (
    [Parameter()]
    [string]$SubscriptionName      = 'Suscripción de Plataformas de MSDN',
    [string]$EnvironmentTagName    = 'Environment',
    [string]$EnvironmentValue      = 'Development',
    [Parameter(mandatory = $true)]
    [string]$RestaurantName
)

$pProject                       = '00003'
$pResourceGroupName             = "$($pProject)-simple-restaurant-menu-$($EnvironmentValue)"
$pBlobStorageContainerName      = "$($RestaurantName)container"
$pWebAppName                    = "$($pProject)-$($RestaurantName)-webapp"
$pServicebusNamespaceName       = "$($pProject)-$($RestaurantName)-sbns"
$pLocation                      = 'chilecentral'

Write-Host "Starting deployment for project: $($pProject)" -BackgroundColor Green
Write-Host "Using subscription: $($SubscriptionName)" -BackgroundColor Green
Write-Host "Resource Group: $($pResourceGroupName)" -BackgroundColor Green
Write-Host "Location: $($pLocation)" -BackgroundColor Green
Write-Host "Storage Account: $($pBlobStorageContainerName)" -BackgroundColor Green
Write-Host "Storage Account: $($pBlobStorageContainerName)" -BackgroundColor Green
Write-Host "Web App: $($pWebAppName)" -BackgroundColor Green
Write-Host "Service Bus Namespace: $($pServicebusNamespaceName)" -BackgroundColor Green


Write-Host "Deploying the resource group: $($pResourceGroupName)" -BackgroundColor Green
az deployment sub create `
    --name $pResourceGroupName `
    --location $pLocation `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$pResourceGroupName pLocation=$pLocation `
    --subscription $SubscriptionName