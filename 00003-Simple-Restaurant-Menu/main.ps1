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
$pStorageAccountName            = "$($pProject)sa"
$pBlobStorageContainerName      = "$($RestaurantName)container"
$pWebAppName                    = "$($pProject)-$($RestaurantName)-webapp"
$pServicebusNamespaceName       = "$($pProject)-$($RestaurantName)-sbns"
$pLocation                      = 'chilecentral'
$pContainersName                = @(
                                        "'Starters'"
                                        "'Mains'"
                                        "'Desserts'"
                                        "'Sides'"
                                        "'Non-Alcoholic Beverages'"
                                        "'Alcoholic Beverages'"
                                        "'Backups'"
                                    )

# Convert the PowerShell array into a compressed JSON string representation
$containersJson = $pContainersName | ConvertTo-Json -Compress

Write-Host "Starting deployment for project: $($pProject)" -BackgroundColor Green
Write-Host "Using subscription: $($SubscriptionName)" -BackgroundColor Green
Write-Host "Resource Group: $($pResourceGroupName)" -BackgroundColor Green
Write-Host "Location: $($pLocation)" -BackgroundColor Green
Write-Host "Storage Account: $($pStorageAccountName)" -BackgroundColor Green
Write-Host "Blob storage container: $($pBlobStorageContainerName)" -BackgroundColor Green
Write-Host "Web App: $($pWebAppName)" -BackgroundColor Green
Write-Host "Service Bus Namespace: $($pServicebusNamespaceName)" -BackgroundColor Green


Write-Host "Deploying the resource group: $($pResourceGroupName)" -BackgroundColor Green
az deployment sub create `
    --name 'az-deploy-sub-01-rg' `
    --location $pLocation `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$pResourceGroupName pLocation=$pLocation `
    --subscription $SubscriptionName

write-host "Deploying the account storage account $($pStorageAccountName)" -BackgroundColor Green
az deployment group create `
    --name 'az-deploy-group-sa-01' `
    --template-file '../infra/bicep/06.- Azure Blob Storage/simple-storage-account-StorageV2-Standard_LRS-Hot.bicep' `
    --parameters storageAccountName=$pStorageAccountName storageAccountLocaltion=$pLocation `
    --resource-group $pResourceGroupName