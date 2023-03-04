function Configure-TerraformWorkspace (
    [parameter(Mandatory=$true)]
    [string]
    $Workspace=($env:TF_WORKSPACE ?? "default")
) {
    $terraformWorkspaceVars = (Join-Path (Split-Path $PSScriptRoot -Parent) terraform "${Workspace}.tfvars")
    if (Test-Path $terraformWorkspaceVars) {
        $regexCallback = {
            $terraformEnvironmentVariableName = "ARM_$($args[0])".ToUpper()
            $script:environmentVariableNames += $terraformEnvironmentVariableName
            "`n`$env:${terraformEnvironmentVariableName}"
        }

        # Match relevant lines first
        $terraformVarsFileContent = (Get-Content $terraformWorkspaceVars | Select-String "(?m)^[^#\w]*(client_id|client_secret|subscription_id|tenant_id)")
        if ($terraformVarsFileContent) {
            $envScript = [regex]::replace($terraformVarsFileContent,"(client_id|client_secret|subscription_id|tenant_id)",$regexCallback,[System.Text.RegularExpressions.RegexOptions]::Multiline)
            if ($envScript) {
                Write-Verbose $envScript
                Invoke-Expression $envScript
            } else {
                Write-Warning "[regex]::replace removed all content from script"
            }
        } else {
            Write-Verbose "No matches"
        }
    }
}

function Get-LoggedInStatus () {
    $loggedIn = $false
    $azureAccount = $null
    az account show 2>$null | ConvertFrom-Json | Set-Variable azureAccount
    if ($azureAccount -and "${env:ARM_TENANT_ID}" -and ($azureAccount.tenantId -ine $env:ARM_TENANT_ID)) {
        Write-Warning "Logged into tenant $($azureAccount.tenant_id) instead of $env:ARM_TENANT_ID (`$env:ARM_TENANT_ID)"
        $azureAccount = $null
    }
    if ($azureAccount) {
        $loggedIn = $true
    }
    return $loggedIn
}

function Get-TerraformDirectory {
    return (Join-Path (Split-Path $PSScriptRoot -Parent) "terraform")
}

function Get-TerraformOutput (
    [parameter(Mandatory=$true)][string]$outputName
) {
    terraform -chdir='../terraform' output -json $outputName 2>$null | ConvertFrom-Json | Write-Output
}

function Login-Az (
    [parameter(Mandatory=$false)][switch]$DisplayMessages=$false
) {
    # Are we logged in? If so, is it the right tenant?
    $loggedIn = Get-LoggedInStatus
    
    $azLoginSwitches = "--allow-no-subscriptions"
    if (-not $azureAccount) {
        if ($env:CODESPACES -ieq "true") {
            $azLoginSwitches += " --use-device-code"
        }
        if ($env:ARM_TENANT_ID) {
            Write-Debug "az login -t ${env:ARM_TENANT_ID} -o none $($azLoginSwitches)"
            az login -t $env:ARM_TENANT_ID -o none $($azLoginSwitches)
        } else {
            Write-Debug "az login -o none $($azLoginSwitches)"
            az login -o none $($azLoginSwitches)
        }
    }

    $loggedIn = Get-LoggedInStatus
    if ($loggedIn) {
        Write-Verbose "Setting TF_VAR_devops_pat, so Terraform azuredevops provider can authenticate to Azure DevOps"
        az account get-access-token --resource 499b84ac-1321-427f-aa17-267ca6975798 `
                                    --query "accessToken" `
                                    --output tsv `
                                    | Set-Item -Path env:TF_VAR_devops_pat
        Write-Debug "TF_VAR_devops_pat: "
        $env:TF_VAR_devops_pat -replace '.','*' | Write-Debug
    } else {
        Write-Warning "Not logged into Azure"
    }
}

function Invoke (
    [string]$cmd
) {
    Write-Host "`n$cmd" -ForegroundColor Green 
    Invoke-Expression $cmd
    Validate-ExitCode $cmd
}

function Open-Browser (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Url
) {
    Write-Verbose "Opening browser to $Url"
    if ($IsLinux) {
        if (Get-Command xdg-open -ErrorAction SilentlyContinue) {
            xdg-open $Url
        } else {
            Write-Warning "xdg-open not found, please open the following URL in your browser:`n${Url}"
        }
    }
    if ($IsMacOS) {
        open $Url
    }
    if ($IsWindows) {
        start $Url
    }
}

function Prompt-User (
    [parameter(Mandatory=$false)][string]
    $PromptMessage = "Continue with next step?",
    [parameter(Mandatory=$false)][string]
    $ContinueMessage = "Continue with next step",
    [parameter(Mandatory=$false)][string]
    $AbortMessage = "Aborting demo"
) {
    $defaultChoice = 0
    # Prompt to continue
    $choices = @(
        [System.Management.Automation.Host.ChoiceDescription]::new("&Continue", $ContinueMessage)
        [System.Management.Automation.Host.ChoiceDescription]::new("&Exit", $AbortMessage)
    )
    $decision = $Host.UI.PromptForChoice("`n", $PromptMessage, $choices, $defaultChoice)
    Write-Debug "Decision: $decision"

    if ($decision -eq 0) {
        Write-Host "$($choices[$decision].HelpMessage)"
    } else {
        Write-Host "$($PSStyle.Formatting.Warning)$($choices[$decision].HelpMessage)$($PSStyle.Reset)"
        exit $decision             
    }
}

function Validate-ExitCode (
    [string]$cmd
) {
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        Write-Warning "'$cmd' exited with status $exitCode"
        exit $exitCode
    }
}

function Write-JsonResponse (
    [parameter(Mandatory=$true)]
    [ValidateNotNull()]
    $Json
) {
    if (Get-Command jq -ErrorAction SilentlyContinue) {
        if ($DebugPreference -ne "SilentlyContinue") {
            $Json | jq -C
        }
        # $Json | jq -C | Write-Debug
    } else {
        Write-Debug $Json
    }
}
