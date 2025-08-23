[CmdletBinding()]
param (
    [Parameter()]
    [string]$pSubscriptionName      = 'Suscripción de Plataformas de MSDN',
    [Parameter()]
    [string]$pManagementGroupName   = 'DEV'

)
#JLopez-20250823: Defining the resource groups to be created.
$rg1 = '00002-project-effect-modify-eforce-tags'
$rg2 = '00002-project-effect-deny-enforce-locations'
$rg3 = '00002-project-effect-deployifnotexists-public-ip'
 
#JLopez-20250508: Deploying the resource group at the subscription level, using a bicep template.
az deployment sub create `
    --name '00002-Deployment-1' `
    --location 'eastus' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$rg1 pLocation='eastus' `
    --subscription $pSubscriptionName

az deployment sub create `
    --name '00002-Deployment-2' `
    --location 'westus' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$rg2 pLocation='westus' `
    --subscription $pSubscriptionName

az deployment sub create `
    --name '00002-Deployment-3' `
    --location 'westus' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$rg3 pLocation='westus' `
    --subscription $pSubscriptionName

#JLopez-20250823: Deploying the azure policy definition
#                 to deploy this template you should have a management group created. 
az deployment mg create `
    --name '00002-Deployment-4' `
    --location 'eastus' `
    --template-file './.policy-definitions/azure-policy-enforce-tags.bicep' `
    --parameters pName='enforce-tags-rg1' pDisplayName='Eforce tags' pCategory='Tags' pTagName='Project' pTagValue='az305' `
    --management-group-id $pManagementGroupName

#JLopez-20250819: Deploying the network interface and the virtual network.
# az deployment group create `
#     --name '00002-Deployment-2' `
#     --parameters pAddressPrefix='11.0.0.0/16' pSubnetPrefix='11.0.0.0/24' `
#     --resource-group $rg1 `
#     --template-file '../infra/bicep/02.- network/vnet-1-subnet-1-nic.bicep' 