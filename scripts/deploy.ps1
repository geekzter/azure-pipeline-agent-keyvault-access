#!/usr/bin/env pwsh
<# 
.SYNOPSIS 
    Deploys Azure resources using Terraform
 
.DESCRIPTION 
    This script is a wrapper around Terraform. It is provided for convenience only, as it works around some limitations in the demo. 
    E.g. terraform might need resources to be started before executing, and resources may not be accessible from the current locastion (IP address).

.EXAMPLE
    ./deploy.ps1 -apply
#> 
#Requires -Version 7.2

### Arguments
param ( 
    [parameter(Mandatory=$false,HelpMessage="Initialize Terraform backend, modules & provider")][switch]$Init=$false,
    [parameter(Mandatory=$false,HelpMessage="Perform Terraform plan stage")][switch]$Plan=$false,
    [parameter(Mandatory=$false,HelpMessage="Perform Terraform validate stage")][switch]$Validate=$false,
    [parameter(Mandatory=$false,HelpMessage="Perform Terraform apply stage (implies plan)")][switch]$Apply=$false,
    [parameter(Mandatory=$false,HelpMessage="Perform Terraform destroy stage")][switch]$Destroy=$false,
    [parameter(Mandatory=$false,HelpMessage="Show Terraform output variables")][switch]$Output=$false,
    [parameter(Mandatory=$false,HelpMessage="Don't show prompts unless something get's deleted that should not be")][switch]$Force=$false
) 

### Internal Functions
. (Join-Path $PSScriptRoot functions.ps1)

### Validation
if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
    $tfMissingMessage = "Terraform not found"
    if ($IsWindows) {
        $tfMissingMessage += "`nInstall Terraform e.g. from Chocolatey (https://chocolatey.org/packages/terraform) 'choco install terraform'"
    } else {
        $tfMissingMessage += "`nInstall Terraform e.g. using tfenv (https://github.com/tfutils/tfenv)"
    }
    throw $tfMissingMessage
}

Write-Information $MyInvocation.line 
$script:ErrorActionPreference = "Stop"

$workspace = Get-TerraformWorkspace
$planFile  = "${workspace}.tfplan".ToLower()
$varsFile  = "${workspace}.tfvars".ToLower()
$inAutomation = ($env:TF_IN_AUTOMATION -ieq "true")
if (($workspace -ieq "prod") -and $Force) {
    $Force = $false
    Write-Warning "Ignoring -Force in workspace '${workspace}'"
}

try {
    $tfdirectory = (Get-TerraformDirectory)
    Push-Location $tfdirectory
    # Print version info
    terraform -version

    if ($Validate) {
        Invoke "terraform validate" 
    }
    
    # Prepare common arguments
    if ($Force) {
        $forceArgs = "-auto-approve"
    }

    if (Test-Path $varsFile) {
        # Load variables from file, if it exists and environment variables have not been set
        $varArgs = " -var-file='$varsFile'"
    }

    if ($Plan -or $Apply -or $Destroy) {
        Login-Az -DisplayMessages
    }

    if ($Plan -or $Apply) {
        # Create plan
        Invoke "terraform plan $varArgs -out='$planFile'"
    }

    if ($Apply) {
        Write-Verbose "Converting $planFile into JSON so we can perform some inspection..."
        $planJSON = (terraform show -json $planFile)
        if ($DebugPreference -ine "SilentlyContinue") {
            New-TemporaryFile | Select-Object -ExpandProperty FullName | Set-Variable jsonPlanFile
            $jsonPlanFile += ".json"
            $planJSON | Set-Content $jsonPlanFile
            Write-Debug "Plan file (json): ${jsonPlanFile}"
        }

        # Check whether key resources will be replaced
        if (Get-Command jq -ErrorAction SilentlyContinue) {
            $psNativeCommandArgumentPassingBackup = $PSNativeCommandArgumentPassing
            try {
                $PSNativeCommandArgumentPassing = "Legacy"
                $linuxVMsReplaced     = $planJSON | jq -r '.resource_changes[] | select(.address|contains(\"azurerm_linux_virtual_machine.\"))             | select( any (.change.actions[];contains(\"delete\"))) | .address'
                Validate-ExitCode "jq"
                $vmsReplaced          = (($linuxVMsReplaced + $linuxVMSSsReplaced + $windowsVMsReplaced + $windowsVMSSsReplaced) -replace '(\w+)(module\.)', "`$1`n`$2")    
            } finally {
                $PSNativeCommandArgumentPassing = $psNativeCommandArgumentPassingBackup
            }
        } else {
            Write-Warning "jq not found, plan validation skipped. Look at the plan carefully before approving"
            if ($Force) {
                $Force = $false # Ignore force if automated vcalidation is not possible
                Write-Warning "Ignoring -force"
            }
        }

        if (!$inAutomation) {
            $defaultChoice = 0
            if ($vmsReplaced) {
                $defaultChoice = 1
                Write-Warning "You're about to remove or replace these Virtual Machines in workspace '${workspace}':"
                $vmsReplaced
                if ($Force) {
                    $Force = $false # Ignore force if resources with state get replaced
                    Write-Warning "Ignoring -force"
                }
            }

            if (!$Force) {
                # Prompt to continue
                $choices = @(
                    [System.Management.Automation.Host.ChoiceDescription]::new("&Continue", "Deploy infrastructure")
                    [System.Management.Automation.Host.ChoiceDescription]::new("&Exit", "Abort infrastructure deployment")
                )
                $decision = $Host.UI.PromptForChoice("`n", "Do you wish to proceed executing Terraform plan $planFile in workspace $workspace?", $choices, $defaultChoice)

                if ($decision -eq 0) {
                    Write-Host "$($choices[$decision].HelpMessage)"
                } else {
                    Write-Host "$($PSStyle.Formatting.Warning)$($choices[$decision].HelpMessage)$($PSStyle.Reset)"
                    exit                    
                }
            }
        }

        Invoke "terraform apply $forceArgs '$planFile'"
    }
    if ($Output) {
        Invoke "terraform output"
    }

    if ($Destroy) {
        Invoke "terraform destroy $varArgs $forceArgs"
    }
} finally {
    Pop-Location
}