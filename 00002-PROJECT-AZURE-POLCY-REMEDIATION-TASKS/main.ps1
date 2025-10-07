#Author:            Jesus Lopez Mesia
#Linkedin:          https://www.linkedin.com/in/susejzepol/
#Created date:      08-05-2025
#Modified date:     10-06-2025

[CmdletBinding()]
param (
    [Parameter()]
    [string]$pSubscriptionName      = 'Suscripción de Plataformas de MSDN'

)

#JLopez-20250823: Defining the resource groups to be created.
$Project                = '00002'
$rg1                    = "$Project-eforce-tags"
$rg2                    = "$Project-deny-locations"
$rg3                    = "$Project-deployifnotexists-nsg"

$policyVersion          = '1.0.0.0'
$PolicyName1            = "$Project-Enforce-tags"
$PolicyName2            = "$Project-Deny-location"
$PolicyName3            = "$Project-Deploy-nsg-if-not-exists"
$PolicyName4            = "$Project-Modify-nic-to-add-nsg"
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


###########################################################################
#JLopez-20251006: RG1.
###########################################################################

#JLopez-20250819: Deploying the network interface and the virtual network.
$subnetID = $(
                az deployment group create `
                    --name '00002-vnet-subnet-Deployment-6' `
                    --resource-group $rg1 `
                    --template-file '../infra/bicep/02.- network/vnet-1-subnet-1.bicep' `
                    --parameters pAddressPrefix='11.1.0.0/16' `
                                    pSubnetPrefix='11.1.0.0/24' `
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

#JLopez-20250823: Deploying the azure policy definition.
az deployment sub create `
    --name '00002-policy1-Deployment-4-1' `
    --location 'eastus' `
    --template-file './.policies/azure-policy-modify-enforce-tags.bicep' `
    --subscription $pSubscriptionName `
    --parameters pName=$PolicyName1 `
                    pCategory='Tags' `
                        pVersion=$policyVersion `
                            pLocation='eastus' `
                                pTagName='Project' `
                                    pTagValue='az305'


###########################################################################
#JLopez-20251006: RG2.
###########################################################################

az deployment sub create `
    --name '00002-policy2-Deployment-4-2' `
    --location 'westus' `
    --template-file './.policies/azure-policy-deny-location.bicep' `
    --subscription $pSubscriptionName `
    --parameters pName=$PolicyName2 `
                    pLocation='westus' `
                        pCategory='Deny' `
                            pVersion=$policyVersion

#JLopez-20250917: Assignin the policy definition.
az deployment group create `
    --name '00002-policy2-Assigment-4-2-1' `
    --template-file './.policies/azure-policy-deny-location-assignment.bicep' `
    --resource-group $rg2 `
    --parameters pName=$PolicyName2 `
                    pLocation='westus'

#JLopez-20250901: Deploying the linux virtual machine in the second resource group.
$subnetID = $(
                az deployment group create `
                    --name '00002-vnet-subnet-Deployment-9' `
                    --resource-group $rg2 `
                    --template-file '../infra/bicep/02.- network/vnet-1-subnet-1.bicep' `
                    --parameters pLocation='brazilus' `
                                    pAddressPrefix='11.2.0.0/16' `
                                        pSubnetPrefix='11.2.0.0/24' `
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
                --name '00002-nic-Deployment-10' `
                --resource-group $rg2 `
                --template-file '../infra/bicep/02.- network/network-interface-nic.bicep' `
                --parameters pVmName=$vmrg2 `
                                pLocation='brazilus' `
                                    pSubnetId=$subnetID `
                                        pProject=$Project `
                --query properties.outputs.nicName.value `
                -o tsv
)

Write-Host "Second VM - NIC: $nicName" -BackgroundColor Green

az deployment group create `
    --name '00002-rg2-vm2-linux-Deployment-11' `
    --resource-group $rg2 `
    --template-file '../infra/bicep/03.- virtual machine/simple-vm-linux-ubuntu.bicep' `
    --parameters pVmSize='Standard_A1_v2' `
                    pProject=$Project `
                        pUserName='azureuser' `
                            pPassword=$pass `
                                pNicName=$nicName `
                                    pLocation='brazilus' `
                                        pVmName=$vmrg2


###########################################################################
#JLopez-20251006: RG3.
###########################################################################

#JLopez-20250922: Deploying the linux virtual machine in the third resource group.
$subnetID = $(
                az deployment group create `
                    --name '00002-vnet-subnet-Deployment-12' `
                    --resource-group $rg3 `
                    --template-file '../infra/bicep/02.- network/vnet-1-subnet-1.bicep' `
                    --parameters pAddressPrefix='11.3.0.0/16' `
                                    pSubnetPrefix='11.3.0.0/24' `
                                        pProject=$Project `
                    --query properties.outputs.subnetID.value `
                    -o tsv
            )
Write-Host "Third subnet: $subnetID" -BackgroundColor Green

$vmrg3 = "$vmGenericName-rg3"

Write-Host "Third VM: $vmrg3" -BackgroundColor Green
#JLopez-20250826: Deploying the NIC.
$nicName = $(
            az deployment group create `
                --name '00002-nic-Deployment-13' `
                --resource-group $rg3 `
                --template-file '../infra/bicep/02.- network/network-interface-nic.bicep' `
                --parameters pVmName=$vmrg3 `
                                pLocation='westus' `
                                    pSubnetId=$subnetID `
                                        pProject=$Project `
                --query properties.outputs.nicName.value `
                -o tsv
)

az deployment group create `
    --name '00002-rg2-vm2-win-Deployment-14' `
    --resource-group $rg3 `
    --template-file '../infra/bicep/03.- virtual machine/simple-vm-windows-2022-smalldisk.bicep' `
    --parameters pVmSize='Standard_A1_v2' `
                    pProject=$Project `
                        pUserName='azureuser' `
                            pPassword=$pass `
                                pNicName=$nicName `
                                    pLocation='westus' `
                                        pVmName=$vmrg3

                                        
###########################################################################
#JLopez-20251006: Deploying the azure policies for the third resource group.
###########################################################################

#JLopez-20251006: First policy definition, deployifnotexists nsg.
Write-Host "Third VM - NIC: $nicName" -BackgroundColor Green
az deployment sub create `
    --name '00002-policy3-Deployment-4-3' `
    --location 'eastus' `
    --template-file './.policies/azure-policy-deployifnotexists.bicep' `
    --subscription $pSubscriptionName `
    --parameters pName=$PolicyName3 `
                    pCategory='Network' `
                        pVersion=$policyVersion `
                            pRGName=$rg3 `
                                pNsgName=$NsgName

#JLopez-20250919: Assigiment the policy definition.
az deployment group create `
    --name '00002-policy3-Assigment-4-3-1' `
    --template-file './.policies/azure-policy-deployifnotexists-assignment.bicep' `
    --resource-group $rg3 `
    --parameters pName=$PolicyName3

#JLopez-20250926: 
# Creating a remediation task for the policy definition deployifnotexists.
# The deployifnotexists effect doesn't automatically remediate existing non-compliant resources.
# we need to create a remediation task to trigger the deployment.
# After the command runs, you can check progress: az policy remediation list --resource-group $rg3 --output table
az policy remediation create `
    --name '00002-policy3-Remediation-4-3-2'  `
    --policy-assignment "Assignment-$PolicyName3" `
    --resource-group $rg3 `
    --resource-discovery-mode 'ReEvaluateCompliance'

#JLopez-20251006: Second policy definition, modify to link the nic to nsg.
az deployment sub create `
    --name '00002-policy4-Deployment-4-4' `
    --location 'eastus' `
    --template-file './.policies/azure-policy-modify-nic-to-add-nsg.bicep' `
    --subscription $pSubscriptionName `
    --parameters pName=$PolicyName3 `
                    pCategory='Network' `
                        pVersion=$policyVersion `
                            pRGName=$rg3 `
                                pNsgName=$NsgName

az deployment group create `
    --name '00002-policy4-Assigment-4-4-1' `
    --template-file './.policies/azure-policy-modify-nic-to-add-nsg-assignment.bicep' `
    --resource-group $rg3 `
    --parameters pName=$PolicyName3

az policy remediation create `
    --name '00002-policy4-Remediation-4-4-2'  `
    --policy-assignment "Assignment-$PolicyName4" `
    --resource-group $rg3 `
    --resource-discovery-mode 'ReEvaluateCompliance'