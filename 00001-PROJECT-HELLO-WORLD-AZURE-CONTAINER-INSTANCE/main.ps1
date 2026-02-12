#Author:            Jesus Lopez Mesia
#Linkedin:          https://www.linkedin.com/in/susejzepol/
#Created date:      06-12-2025
#Modified date:     11-02-2026

[cmdletBinding()]
param(
    [parameter(Mandatory=$true,HelpMessage='Name of the subscription to use in the script.')]
    [string]$SubscriptionName = 'Suscripción de Plataformas de MSDN', 
    [parameter(Mandatory=$true)]
    [string]$ImageName,
    [parameter(Mandatory=$true)]
    [string]$Environment = 'Development'
)

#JLopez-20251222: Defining the resource groups to be created.
$pSubscriptionName              = $SubscriptionName
$pProjectPrefix                 = "00001-$($Environment)"
$pResourceGroupName             = "$($pProjectPrefix)-RG1-ACI"
#JLopez-20251222: This resource group will contain shared resources for all subprojects.
$pResourceGroupInfraName        = "RG-INFRA"
#JLopez-202251226: This is the image name that you built previously in your local machine.
#                  To more information about how to build the image, please check the README.md file for this project.
$pImage                         = $ImageName 

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
$DeploymentName = "$($pProjectPrefix)-rg1-Deployment-1"
az deployment sub create `
    --name $DeploymentName `
    --location 'chilecentral' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$pResourceGroupName pLocation='chilecentral' `
    --subscription $pSubscriptionName

Write-Host "Deploying the Azure Container Registry" -BackgroundColor Green

$pMyNameACR = $(
        az acr list `
            --resource-group $pResourceGroupInfraName `
            --query "[?contains(name, 'myacr')].name" `
            -o tsv
)

$pMyNameACR = $(
    az deployment group create `
    --name "$($pProjectPrefix)-acr-infra-deployment-2" `
    --resource-group $pResourceGroupInfraName `
    --template-file '../infra/bicep/04.- Azure Container Registry/deploy-my-acr.bicep' `
    --parameters acrName=$pMyNameACR `
    --subscription $pSubscriptionName `
    --query properties.outputs.acrName.value `
    -o tsv
).Replace('"','')

Write-Host "Logging in to the Azure Container Registry: $($pMyNameACR)" -BackgroundColor Green
$pAcr_login  = $(az acr show --name $pMyNameACR --resource-group $pResourceGroupInfraName --query "loginServer" -o tsv)
az acr login --name $pAcr_login --resource-group $pResourceGroupInfraName

Write-host "Building the docker image: $pImage" -BackgroundColor Green
docker build -t $pImage --file './My-Hello-world-api/My_Hello_World_Api/Dockerfile' './My-Hello-world-api/My_Hello_World_Api'

Write-Host "Pushing the docker image to the Container Registry" -BackgroundColor Green
$pFull_image = $pAcr_login + "/" + $pImage
docker tag $pImage $pFull_image

write-host "Full image name: $pFull_image" -BackgroundColor Green
docker push $pFull_image

Write-Host "Getting the ACR credentials" -BackgroundColor Green
$acrUser = (az acr credential show --name $pMyNameACR --resource-group $pResourceGroupInfraName --query "username" -o tsv)
$acrPass = (az acr credential show --name $pMyNameACR --resource-group $pResourceGroupInfraName --query "passwords[0].value" -o tsv)

Write-Host "Deploying the Azure Container Instance" -BackgroundColor Green
$container_ip = $(
            az deployment group create `
                --name "$($pProjectPrefix)-aci-deployment-3" `
                --resource-group $pResourceGroupName `
                --template-file '../infra/bicep/05.- Azure Container Instance/simple-aci.bicep' `
                --parameters acrLoginServer=$pAcr_login `
                    image=$pFull_image `
                        acrUser=$acrUser `
                            acrPassword=$acrPass `
                                envAppEnvironment=$Environment `
                --subscription $pSubscriptionName `
                --query properties.outputs.containerIP.value
).trim('"')

Write-Host "API Information" -BackgroundColor Green
write-Host "API URL: http://$($container_ip):8080/"  -BackgroundColor Green
write-Host "INFO URL: http://$($container_ip):8080/Environment_information"  -BackgroundColor Green