#Author:            Jesus Lopez Mesia
#Linkedin:          https://www.linkedin.com/in/susejzepol/
#Created date:      08-05-2025
#Modified date:     12-01-2025

[CmdletBinding()]
param (
    [Parameter()]
    [string]$pSubscriptionName      = 'Suscripción de Plataformas de MSDN',
    [string]$ProjectTagName         = 'Project',
    [string]$ProjectTagValue        = 'az305',
    [securestring]$pPassword
)

#JLopez-20250823: Defining the resource groups to be created.
$Project                = '00002'
$rg1                    = "$Project-tags-deployifnotexists-nsg"
$rg2                    = "$Project-deny-locations"

$policyVersion          = '1.0.0.0'
$PolicyName1            = "$Project-Enforce-tags"
$PolicyName2            = "$Project-Deploy-nsg-if-not-exists"
$PolicyName3            = "$Project-Modify-nic-to-add-nsg"
$PolicyName4            = "$Project-Deny-location"

$NsgName                = "$Project-nsg"
$vmGenericName          = 'vm'

Write-Host "Starting deployment for project: $Project" -BackgroundColor Green

try {

    if(-not $pPassword){
        write-Host "No password provided. Please update the script to handle passwords securely." -BackgroundColor Yellow
        $pass = $null
        $pass = Read-Host "Enter the password for all the virtual machines" -AsSecureString
    }else{
        Write-Host "Password provided via parameter." -BackgroundColor Green
        $bstr = $null
        $pass = $null
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pPassword)
        $pass = [Runtime.InteropServices.Marshal]::PtrToStringUni($bstr)
    }

    # ##########################################################################
    # JLopez-20250508: Deploying resources groups.
    # ##########################################################################

    #JLopez-20250508: Deploying the resource group at the subscription level, using a bicep template.
    $outRg1Id = $(
        az deployment sub create `
            --name '00002-rg1-Deployment-1' `
            --location 'westus' `
            --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
            --parameters pName=$rg1 pLocation='westus' `
            --subscription $pSubscriptionName `
            --query properties.outputs.resourceGroupId.value `
            -o tsv
    )


    az deployment sub create `
        --name '00002-rg2-Deployment-2' `
        --location 'westus' `
        --template-file '../infra/bicep/01.- resource-group/resource-group.bicep' `
        --parameters pName=$rg2 pLocation='westus' `
        --subscription $pSubscriptionName

    # ##########################################################################
    # JLopez-20251006: RG1.
    # ##########################################################################

    #JLopez-20250922: Deploying the linux virtual machine in the third resource group.
    $subnetID = $(
                    az deployment group create `
                        --name '00002-rg1-vnet-subnet-Deployment-1' `
                        --resource-group $rg1 `
                        --template-file '../infra/bicep/02.- network/vnet-1-subnet-1.bicep' `
                        --parameters pAddressPrefix='11.3.0.0/16' `
                                        pSubnetPrefix='11.3.0.0/24' `
                                            pProject=$Project `
                        --query properties.outputs.subnetID.value `
                        -o tsv
                )
    Write-Host "First subnet: $subnetID" -BackgroundColor Green

    $vmrg1 = "$vmGenericName-rg1"

    Write-Host "First VM: $vmrg1" -BackgroundColor Green
    #JLopez-20250826: Deploying the NIC.
    $outNicName = $(
                az deployment group create `
                    --name '00002-rg1-nic-Deployment-2' `
                    --resource-group $rg1 `
                    --template-file '../infra/bicep/02.- network/network-interface-nic.bicep' `
                    --parameters pVmName=$vmrg1 `
                                    pLocation='westus' `
                                        pSubnetId=$subnetID `
                                            pProject=$Project `
                    --query properties.outputs.nicName.value `
                    -o tsv
    )

    az deployment group create `
        --name '00002-rg1-vm2-win-Deployment-3' `
        --resource-group $rg1 `
        --template-file '../infra/bicep/03.- virtual machine/simple-vm-windows-2022-smalldisk.bicep' `
        --parameters pVmSize='Standard_A1_v2' `
                        pProject=$Project `
                            pUserName='azureuser' `
                                pPassword=$pass `
                                    pNicName=$outNicName `
                                        pLocation='westus' `
                                            pVmName=$vmrg1
                                            
    ###########################################################################
    #JLopez-20251006: Deploying the azure policies for the first resource group.
    ###########################################################################

    #JLopez-20250823: Deploying the azure policy definition.
    az deployment sub create `
        --name '00002-rg1-policy1-Deployment-4-1' `
        --location 'westus' `
        --template-file './.policies/azure-policy-modify-enforce-tags.bicep' `
        --subscription $pSubscriptionName `
        --parameters pName=$PolicyName1 `
                        pCategory='Tags' `
                            pVersion=$policyVersion `
                                pTagName=$ProjectTagName `
                                    pTagValue=$ProjectTagValue

    #JLopez-20250919: Assigiment the policy definition.
    $outPolicyAssignmentId = $(
                                az deployment group create `
                                    --name '00002-rg1-policy1-Assigment-4-2' `
                                    --template-file './.policies/azure-policy-modify-enforce-tags-assignment.bicep' `
                                    --resource-group $rg1 `
                                    --parameters pName=$PolicyName1 `
                                                    pLocation='westus' `
                                    --query properties.outputs.policyAssignmentId.value `
                                    -o tsv
                            )

    #JLopez-20251027: Adding the tag contributor role to the policy assignment.
    az role assignment create `
        --assignee-object-id $outPolicyAssignmentId `
        --assignee-principal-type 'ServicePrincipal' `
        --role 'Tag Contributor' `
        --scope $outRg1Id

    #JLopez-20251027: Creating a remediation task for the policy definition enforce-tags.
    az policy remediation create `
        --name '00002-rg1-policy1-Remediation-4-3'  `
        --policy-assignment "Assignment-$PolicyName1" `
        --resource-group $rg1 `
        --resource-discovery-mode 'ReEvaluateCompliance'

    #JLopez-20251006: First policy definition, deployifnotexists nsg.
    Write-Host "first VM - NIC: $outNicName" -BackgroundColor Green
    $outNsgName = $(
                    az deployment sub create `
                        --name '00002-rg1-policy2-Deployment-5-1' `
                        --location 'westus' `
                        --template-file './.policies/azure-policy-deployifnotexists.bicep' `
                        --subscription $pSubscriptionName `
                        --parameters pName=$PolicyName2 `
                                        pCategory='Network' `
                                            pVersion=$policyVersion `
                                                pRGName=$rg1 `
                                                    pNsgName=$NsgName `
                        --query properties.outputs.nsgName.value `
                        -o tsv
                    )

    #JLopez-20250919: Assigiment the policy definition.
    az deployment group create `
        --name '00002-rg1-policy2-Assigment-5-2' `
        --template-file './.policies/azure-policy-deployifnotexists-assignment.bicep' `
        --resource-group $rg1 `
        --parameters pName=$PolicyName2

    #JLopez-20250926: 
    # Creating a remediation task for the policy definition deployifnotexists.
    # The deployifnotexists effect doesn't automatically remediate existing non-compliant resources.
    # we need to create a remediation task to trigger the deployment.
    # After the command runs, you can check progress: az policy remediation list --resource-group $rg1 --output table
    az policy remediation create `
        --name '00002-rg1-policy2-Remediation-5-3'  `
        --policy-assignment "Assignment-$PolicyName2" `
        --resource-group $rg1 `
        --resource-discovery-mode 'ReEvaluateCompliance'

    #JLopez-20251006: Second policy definition, modify to link the nic to nsg.
    az deployment sub create `
        --name '00002-rg1-policy3-Deployment-6-1' `
        --location 'westus' `
        --template-file './.policies/azure-policy-modify-nic-to-add-nsg.bicep' `
        --subscription $pSubscriptionName `
        --parameters pName=$PolicyName3 `
                        pCategory='Network' `
                            pVersion=$policyVersion `
                                pRGName=$rg1 `
                                    pNsgName=$outNsgName `
                                        pNicName=$outNicName

    az deployment group create `
        --name '00002-rg1-policy3-Assigment-6-2' `
        --template-file './.policies/azure-policy-modify-nic-to-add-nsg-assignment.bicep' `
        --resource-group $rg1 `
        --parameters pName=$PolicyName3

    az policy remediation create `
        --name '00002-rg1-policy3-Remediation-6-3'  `
        --policy-assignment "Assignment-$PolicyName3" `
        --resource-group $rg1 `
        --resource-discovery-mode 'ReEvaluateCompliance'

    ###########################################################################
    #JLopez-20251006: RG2.
    ###########################################################################

    az deployment sub create `
        --name '00002-rg2-policy4-Deployment-7-1' `
        --location 'westus' `
        --template-file './.policies/azure-policy-deny-location.bicep' `
        --subscription $pSubscriptionName `
        --parameters pName=$PolicyName4 `
                        pLocation='westus' `
                            pCategory='Deny' `
                                pVersion=$policyVersion

    #JLopez-20250917: Assignin the policy definition.
    az deployment group create `
        --name '00002-rg2-policy4-Assigment-7-2' `
        --template-file './.policies/azure-policy-deny-location-assignment.bicep' `
        --resource-group $rg2 `
        --parameters pName=$PolicyName4 `
                        pLocation='westus'
    try {
        #JLopez-20250901: Deploying the linux virtual machine in the second resource group.
        $subnetID = $(
                        az deployment group create `
                            --name '00002-rg2-vnet-subnet-Deployment-8' `
                            --resource-group $rg2 `
                            --template-file '../infra/bicep/02.- network/vnet-1-subnet-1.bicep' `
                            --parameters pLocation='eastus2' `
                                            pAddressPrefix='11.2.0.0/16' `
                                                pSubnetPrefix='11.2.0.0/24' `
                                                    pProject=$Project `
                            --query properties.outputs.subnetID.value `
                            -o tsv
                    )
        Write-Host "Second subnet: $subnetID" -BackgroundColor Green
    }
    catch {
        if($_.Exception.Message -like "*PolicyViolation*"){
            Write-Host "Can't deploy the subnet on resource group ($rg2) .Deployment blocked by 'Deny location' policy as expected." -BackgroundColor Yellow}
    }

    try {
        $vmrg2 = "$vmGenericName-rg2"

        Write-Host "Second VM: $vmrg2" -BackgroundColor Green
        #JLopez-20250826: Deploying the NIC.
        $outNicName = $(
                    az deployment group create `
                        --name '00002-rg2-nic-Deployment-9' `
                        --resource-group $rg2 `
                        --template-file '../infra/bicep/02.- network/network-interface-nic.bicep' `
                        --parameters pVmName=$vmrg2 `
                                        pLocation='eastus2' `
                                            pSubnetId=$subnetID `
                                                pProject=$Project `
                        --query properties.outputs.nicName.value `
                        -o tsv
        )

        Write-Host "Second VM - NIC: $outNicName" -BackgroundColor Green
    }
    catch {
        if($_.Exception.Message -like "*PolicyViolation*"){
            Write-Host "Can't deploy the nic on resource group ($rg2) .Deployment blocked by 'Deny location' policy as expected." -BackgroundColor Yellow}
    }

    try {
        az deployment group create `
            --name '00002-rg2-vm2-linux-Deployment-10' `
            --resource-group $rg2 `
            --template-file '../infra/bicep/03.- virtual machine/simple-vm-linux-ubuntu.bicep' `
            --parameters pVmSize='Standard_A1_v2' `
                            pProject=$Project `
                                pUserName='azureuser' `
                                    pPassword=$pass `
                                        pNicName=$outNicName `
                                            pLocation='eastus2' `
                                                pVmName=$vmrg2
    }
    catch {
        if($_.Exception.Message -like "*PolicyViolation*"){
            Write-Host "Can't deploy the vdi on resource group ($rg2) .Deployment blocked by 'Deny location' policy as expected." -BackgroundColor Yellow}
    }
}
catch {
   if ($bstr) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    $Pass = $null
}