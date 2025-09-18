#Author:            Jesus Lopez Mesia
#Linkedin:          https://www.linkedin.com/in/susejzepol/
#Created date:      08-05-2025
#Modified date:     09-17-2025

[CmdletBinding()]
param (
    [Parameter()]
    [string]$pSubscriptionName      = 'Suscripción de Plataformas de MSDN'

)
#JLopez-20250823: Defining the resource groups to be created.
$Project                = '00002'
$rg1                    = '00002-eforce-tags'
$rg2                    = '00002-deny-locations'
$rg3                    = '00002-deployifnotexists-nsg'

$policyVersion          = '1.0.0'
$PolicyName1            = "$Project-Enforce-tags"
$PolicyDisplayName1     = 'Eforce tags'
$PolicyName2            = "$Project-Deny-location"
$PolicyDisplayName2     = 'Deny deployments in specific locations'
$PolicyName3            = "$Project-Deploy-nsg-if-not-exists"
$PolicyDisplayName3     = 'Deploy NSG if not exists'
$NsgName                = "$Project-nsg"
$vmGenericName          = 'vm'

#JLopez-20250508: Deploying the resource group at the subscription level, using a bicep template.
az deployment sub create `
    --name '00002-rg1-Deployment-1' `
    --location 'eastus' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$rg1 pLocation='eastus' `
    --subscription $pSubscriptionName

az deployment sub create `
    --name '00002-rg2-Deployment-2' `
    --location 'westus' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$rg2 pLocation='westus' `
    --subscription $pSubscriptionName

az deployment sub create `
    --name '00002-rg3-Deployment-3' `
    --location 'westus' `
    --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
    --parameters pName=$rg3 pLocation='westus' `
    --subscription $pSubscriptionName

#JLopez-20250823: Deploying the azure policy definition.
az deployment sub create `
    --name '00002-policy1-Deployment-4-1' `
    --location 'eastus' `
    --template-file './.policies/azure-policy-enforce-tags.bicep' `
    --subscription $pSubscriptionName `
    --parameters pName=$PolicyName1 `
                    pDisplayName=$PolicyDisplayName1 `
                        pCategory='Tags' `
                            pVersion=$policyVersion `
                                pProject=$Project `
                                    pLocation='eastus' `
                                        pTagName='Project' `
                                            pTagValue='az305'

az deployment sub create `
    --name '00002-policy2-Deployment-4-2' `
    --location 'westus' `
    --template-file './.policies/azure-policy-deny-location.bicep' `
    --subscription $pSubscriptionName `
    --parameters pName=$PolicyName2 `
                    pLocation='westus' `
                        pDisplayName=$PolicyDisplayName2 `
                            pCategory='Deny'

# #JLopez-20250917: Assignin the policy definition.
az deployment group create `
    --name '00002-policy2-Assigment-4-2-1' `
    --template-file './.policies/azure-policy-deny-location-assigment.bicep' `
    --resource-group $rg2 `
    --parameters pName=$PolicyName2 `
                    pLocation='westus' `
                        pDisplayName=$PolicyDisplayName2 `
                            pProject=$Project

az deployment sub create `
    --name '00002-policy2-Deployment-4-3' `
    --location 'eastus' `
    --template-file './.policies/azure-policy-deployifnotexists.bicep' `
    --subscription $pSubscriptionName `
    --parameters pName=$PolicyName3 `
                    pDisplayName=$PolicyDisplayName3 `
                        pCategory='Network' `
                            pProject=$Project `
                                pRGName=$rg3 `
                                    pNsgName=$NsgName
    
#JLopez-20250819: Deploying the network interface and the virtual network.
$subnetID = $(
                az deployment group create `
                    --name '00002-vnet-subnet-Deployment-6' `
                    --resource-group $rg1 `
                    --template-file '../infra/bicep/02.- network/vnet-1-subnet-1.bicep' `
                    --parameters pAddressPrefix='11.0.0.0/16' `
                                    pSubnetPrefix='11.0.0.0/24' `
                                        pProject=$Project `
                    --query properties.outputs.subnetID.value `
                    -o tsv
            )
Write-Host "First subnet: $subnetID" -BackgroundColor Green

$vmrg1 = "$vmGenericName-rg1"

Write-Host "First VM: $vmrg1" -BackgroundColor Green
#JLopez-20250826: Deploying the NIC.
$nicName = $(
            az deployment group create `
                --name '00002-nic-Deployment-7' `
                --resource-group $rg1 `
                --template-file '../infra/bicep/02.- network/network-interface-nic.bicep' `
                --parameters pVmName=$vmrg1 `
                                pLocation='eastus' `
                                    pSubnetId=$subnetID `
                                        pProject=$Project `
                --query properties.outputs.nicName.value `
                -o tsv
)

Write-Host "First VM - NIC: $nicName" -BackgroundColor Green

$pass = Read-Host "Enter the password for all the virtual machines" -AsSecureString

#JLopez-20250808: Deploying the virtual machine.
az deployment group create `
    --name '00002-rg1-vm1-win-Deployment-8' `
    --resource-group $rg1 `
    --template-file '../infra/bicep/03.- virtual machine/simple-vm-windows-2022-smalldisk.bicep' `
    --parameters pVmSize='Standard_A1_v2' `
                    pProject=$Project `
                        pUserName='azureuser' `
                            pPassword=$pass `
                                pNicName=$nicName `
                                    pLocation='eastus' `
                                        pVmName=$vmrg1

#JLopez-20250901: Deploying the linux virtual machine in the second resource group.
$subnetID = $(
                az deployment group create `
                    --name '00002-vnet-subnet-Deployment-9' `
                    --resource-group $rg2 `
                    --template-file '../infra/bicep/02.- network/vnet-1-subnet-1.bicep' `
                    --parameters pAddressPrefix='11.0.0.0/16' `
                                    pSubnetPrefix='11.0.0.0/24' `
                                        pProject=$Project `
                    --query properties.outputs.subnetID.value `
                    -o tsv
            )
Write-Host "Second subnet: $subnetID" -BackgroundColor Green

$vmrg2 = "$vmGenericName-rg2"

Write-Host "Second VM: $vmrg2" -BackgroundColor Green
#JLopez-20250826: Deploying the NIC.
$nicName = $(
            az deployment group create `
                --name '00002-nic-Deployment-9' `
                --resource-group $rg2 `
                --template-file '../infra/bicep/02.- network/network-interface-nic.bicep' `
                --parameters pVmName=$vmrg2 `
                                pLocation='westus' `
                                    pSubnetId=$subnetID `
                                        pProject=$Project `
                --query properties.outputs.nicName.value `
                -o tsv
)

Write-Host "Second VM - NIC: $nicName" -BackgroundColor Green

az deployment group create `
    --name '00002-rg2-vm2-linux-Deployment-8' `
    --resource-group $rg2 `
    --template-file '../infra/bicep/03.- virtual machine/simple-vm-linux-ubuntu.bicep' `
    --parameters pVmSize='Standard_A1_v2' `
                    pProject=$Project `
                        pUserName='azureuser' `
                            pPassword=$pass `
                                pNicName=$nicName `
                                    pLocation='westus' `
                                        pVmName=$vmrg2