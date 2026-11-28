#Author:            Jesus Lopez Mesia
#Linkedin:          https://www.linkedin.com/in/susejzepol/
#Created date:      13-08-2026
#Modified date:     27-11-2026

[CmdletBinding()]
param (
    [Parameter(mandatory = $true)]
    [string]$SubscriptionId,
    [Parameter(mandatory = $true)]
    [string]$RestaurantName,
    [string]$EnvironmentTagName    = 'Environment',
    [Parameter(mandatory = $true)]
    [string]$EnvironmentValue
)

$pUserUpn                       = $(az ad signed-in-user show --query userPrincipalName -o tsv)
$pRestaurantName                = $RestaurantName.ToLower()
$pProject                       = '00003'
$pResourceGroupName             = "$($pProject)-$($pRestaurantName)-simple-restaurant-menu-$($EnvironmentValue)"
$pStorageAccountName            = "$($pProject)$($pRestaurantName)sa"
$pBlobStorageContainerName      = "$($RestaurantName)container"
$pWebAppName                    = "$($pProject)-$($RestaurantName)-webapp"
$pServicebusNamespaceName       = "$($pProject)-$($RestaurantName)-sbns"
$pLocation                      = 'chilecentral'
$pContainersName                = 'starters,mains,desserts,sides,non-alcoholic-beverages,alcoholic-beverages'

#JLopez-2026/NOV/27: Throw an error if the EnvironmentValue is not one of the accepted values: 'Dev', 'Development', 'Prod' or 'Production'.

if ($EnvironmentValue.ToUpperInvariant() -notin @('DEV', 'DEVELOPMENT', 'PROD', 'PRODUCTION')) {
    throw "Invalid value for EnvironmentValue. Please specify one of the following: 'Dev', 'Development', 'Prod', or 'Production'."
}

Write-Host "Starting deployment for project: $($pProject)" -BackgroundColor Green
Write-Host "Using subscription: $($SubscriptionId)" -BackgroundColor Green
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
    --subscription $SubscriptionId

write-host "Deploying the account storage account $($pStorageAccountName)" -BackgroundColor Green
$ContainersName = (
    az deployment group create `
        --name 'az-deploy-group-sa-01' `
        --template-file '../infra/bicep/06.- Azure Blob Storage/simple-storage-account-StorageV2-Standard_LRS-Hot.bicep' `
        --parameters storageAccountName=$pStorageAccountName storageAccountLocaltion=$pLocation containerNames=$pContainersName `
        --resource-group $pResourceGroupName `
        --query properties.outputs.outContainersCreated.value `
        --output tsv
)

Write-Host "Assigning the 'Storage Blob Data Contributor' role to the current account." -BackgroundColor Green

$storageAccountId = $(az storage account show --name $pStorageAccountName --resource-group $pResourceGroupName --query id -o tsv)

az role assignment create `
    --assignee $pUserUpn `
    --role "Storage Blob Data Contributor" `
    --scope $storageAccountId

Write-Host "The following containers were created in the storage account: $($pStorageAccountName)" -BackgroundColor Yellow
$ContainersName | 
        ForEach-Object {
            Write-Host "Container: [$PSItem]"
            Write-Host "Uploading files into the container: $($PSItem)"
            $menu_option_path = "./images/$($PSItem)"
            Write-Host "Local path: $($menu_option_path)"

            ForEach($image in Get-ChildItem -Path $menu_option_path -name) 
            {
                $full_image_path = $($menu_option_path + "/" + $image)
                Write-Host "Found file: $($image)"

                az storage blob upload `
                    --account-name $pStorageAccountName `
                    --container-name $PSItem `
                    --name "$($image)" `
                    --file "$($full_image_path)" `
                    --auth-mode login `
                    --overwrite true
            }

            Write-Host "All files uploaded to container: $($PSItem)" -BackgroundColor Yellow
        }

#JLopez-2026/NOV/27: If $EnvironmentValue is equal to 'Prod' or 'Production', then the storage account 
#                    public access should be disabled. Otherwise, it should be enabled for 'Dev' or 'Test' environments.
if ($EnvironmentValue.ToUpperInvariant() -eq 'PROD' -or $EnvironmentValue.ToUpperInvariant() -eq 'PRODUCTION') {
    Write-Host "Disabling public access to the storage account: $($pStorageAccountName)" -BackgroundColor Green
    az storage account update `
        --name $pStorageAccountName `
        --resource-group $pResourceGroupName `
        --public-network-access Disabled
}