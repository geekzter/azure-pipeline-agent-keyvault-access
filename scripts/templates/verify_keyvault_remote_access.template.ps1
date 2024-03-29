#!/usr/bin/env pwsh
<# 
.SYNOPSIS 
    This file is generated by Terraform
    https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
    https://www.terraform.io/language/functions/templatefile
#> 

if (!(Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Warning "Azure CLI not found. Please install it."
    exit 1
}
if (!(az extension list --query "[?name=='azure-devops'].version" -o tsv)) {
    Write-Host "Adding Azure CLI extension 'ssh'..."
    az extension add -n ssh -y
}

Write-Host "This script will verify private Key Vault access by executing data plane command 'az keyvault secret list' on agent ${agentName}..."
Write-Output 'az login --identity -u ${identityObjectId};az keyvault secret list --vault-name ${keyVaultName} --subscription ${subscriptionId} -o table' | `
              az network bastion ssh --ids ${bastionId} `
                                     --target-resource-id ${vmId} `
                                     --auth-type ssh-key `
                                     --username ${userName} `
                                     --ssh-key ${sshPrivateKey}
