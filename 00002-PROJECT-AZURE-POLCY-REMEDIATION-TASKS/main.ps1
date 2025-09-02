#Author:            Jesus Lopez Mesia
#Linkedin:          https://www.linkedin.com/in/susejzepol/
#Created date:      08-05-2025
#Modified date:     08-28-2025

[CmdletBinding()]
param (
    [Parameter()]
    [string]$pSubscriptionName      = 'Suscripción de Plataformas de MSDN',
    [Parameter()]
    [string]$pManagementGroupName   = 'DEV'

)
#JLopez-20250823: Defining the resource groups to be created.
$rg1                    = '00002-project-effect-modify-eforce-tags-1'
$rg2                    = '00002-project-effect-deny-enforce-locations-1'
$rg3                    = '00002-project-effect-deployifnotexists-public-ip-1'
$PolicyDisplayName      = 'Eforce tags 1'
$policyVersion          = '1.0.0'
$PolicyName             = 'enforce-tags-rg1-1'
$PolicyAssignmentName   = $PolicyName + '-assignment'
$vmGenericName          = 'vm-'

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
    --name '00002-policy1def-Deployment-4' `
    --location 'eastus' `
    --template-file './.policy-definitions/azure-policy-enforce-tags.bicep' `
    --subscription $pSubscriptionName `
    --parameters pName=$PolicyName `
                    pDisplayName=$PolicyDisplayName `
                        pCategory='Tags' `
                            pTagName='Project' `
                                pTagValue='az305' `
                                    pVersion=$policyVersion 


#JLopez-20250825: Assignin the policy definition.
$policyID = $(az policy definition list --query "[?name=='$PolicyName'].id" -o tsv)

Write-Host "Policy ID: $policyID" -BackgroundColor Green

az deployment group create `
    --name '00002-policyAssg-Deployment-5' `
    --template-file './.policy-assignments\azure-policy-assignments.bicep' `
    --resource-group $rg1 `
    --parameters pAssignmentName=$PolicyAssignmentName `
                pDefinitionID=$policyID `
                    pDisplayName="Enforce tags assignment to $rg1" `
                        pDescription="This policy enforce tags to all the resources in the resource group: $rg1" `
                            pMessage='Adding default tags to this resource.' 
    
#JLopez-20250819: Deploying the network interface and the virtual network.
$subnetID = $(
                az deployment group create `
                    --name '00002-vnet-subnet-Deployment-6' `
                    --parameters pAddressPrefix='11.0.0.0/16' pSubnetPrefix='11.0.0.0/24' `
                    --resource-group $rg1 `
                    --template-file '../infra/bicep/02.- network/vnet-1-subnet-1.bicep' `
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
                                        pProject='00002' `
                --query properties.outputs.nicName.value `
                -o tsv
)

Write-Host "First VM - NIC: $nicName" -BackgroundColor Green

$pass = Read-Host "Enter the password for all the virtual machines" -AsSecureString

#JLopez-20250808: Deploying the virtual machine.
az deployment group create `
    --name '00002-rg1-vm1-win-Deployment-8' `
    --resource-group $rg1 `
    --template-file '../infra/bicep/03.- virtual machine/simple-vm-windows-2012-R2.bicep' `
    --parameters pVmSize='Standard_A1_v2' `
                    pProject='00002' `
                        pUserName='azureuser' `
                            pPassword=$pass`
                                pNicName=$nicName `
                                    pLocation='eastus' `
                                        pVmName=$vmrg1

#JLopez-20250901: Deploying the linux virtual machine in the second resource group.
$vmrg2 = "$vmGenericName-rg2"
az deployment group create `
    --name '00002-rg2-vm2-linux-Deployment-8' `
    --resource-group $rg2 `
    --template-file '../infra/bicep/03.- virtual machine/simple-vm-linux-ubuntu.bicep' `
    --parameters pVmSize='Standard_A1_v2' 
                    pProject='00002' `
                        pUserName='azureuser' `
                            pPassword=$pass`
                                pNicName=$nicName `
                                    pLocation='eastus'
                                        pVmName=$vmrg2