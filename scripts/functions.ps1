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
    } elseif ($azureAccount) {
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
    if (!$loggedIn) {
        if ($env:CODESPACES -ieq "true") {
            $azLoginSwitches = "--use-device-code"
        }
        if ($env:ARM_TENANT_ID) {
            az login -t $env:ARM_TENANT_ID -o none $($azLoginSwitches)
        } else {
            az login -o none $($azLoginSwitches)
        }
    }

    $loggedIn = Get-LoggedInStatus
    if (!$loggedIn) {
        Write-Warning "Not logged into Azure"
        exit 1
    }

    if ($env:ARM_SUBSCRIPTION_ID) {
        az account set -s $env:ARM_SUBSCRIPTION_ID -o none
    }
    
    if ($DisplayMessages) {
        if ($env:ARM_SUBSCRIPTION_ID -or ($(az account list --query "length([])" -o tsv) -eq 1)) {
            Write-Host "Using subscription '$(az account show --query "name" -o tsv)'"
        } else {
            if ($env:TF_IN_AUTOMATION -ine "true") {
                # Active subscription may not be the desired one, prompt the user to select one
                $subscriptions = (az account list --query "sort_by([].{id:id, name:name},&name)" -o json | ConvertFrom-Json) 
                $index = 0
                $subscriptions | Format-Table -Property @{name="index";expression={$script:index;$script:index+=1}}, id, name
                Write-Host "Set `$env:ARM_SUBSCRIPTION_ID to the id of the subscription you want to use to prevent this prompt" -NoNewline

                do {
                    Write-Host "`nEnter the index # of the subscription you want Terraform to use: " -ForegroundColor Cyan -NoNewline
                    $occurrence = Read-Host
                } while (($occurrence -notmatch "^\d+$") -or ($occurrence -lt 1) -or ($occurrence -gt $subscriptions.Length))
                $env:ARM_SUBSCRIPTION_ID = $subscriptions[$occurrence-1].id
            
                Write-Host "Using subscription '$($subscriptions[$occurrence-1].name)'" -ForegroundColor Yellow
                Start-Sleep -Seconds 1
            } else {
                Write-Host "Using subscription '$(az account show --query "name" -o tsv)', set `$env:ARM_SUBSCRIPTION_ID if you want to use another one"
            }
        }
    }

    # Populate Terraform azurerm variables where possible
    if ($userType -ine "user") {
        # Pass on pipeline service principal credentials to Terraform
        $env:ARM_CLIENT_ID       ??= $env:servicePrincipalId
        $env:ARM_CLIENT_SECRET   ??= $env:servicePrincipalKey
        $env:ARM_TENANT_ID       ??= $env:tenantId
        # Get from Azure CLI context
        $env:ARM_TENANT_ID       ??= $(az account show --query tenantId -o tsv)
        $env:ARM_SUBSCRIPTION_ID ??= $(az account show --query id -o tsv)
    }
    # # Variables for Terraform azurerm Storage backend
    # if (!$env:ARM_ACCESS_KEY -and !$env:ARM_SAS_TOKEN) {
    #     if ($env:TF_VAR_backend_storage_account -and $env:TF_VAR_backend_storage_container) {
    #         $env:ARM_SAS_TOKEN=$(az storage container generate-sas -n $env:TF_VAR_backend_storage_container --as-user --auth-mode login --account-name $env:TF_VAR_backend_storage_account --permissions acdlrw --expiry (Get-Date).AddDays(7).ToString("yyyy-MM-dd") -o tsv)
    #     }
    # }

    # Propagate token to azuredevops provider
    Write-Verbose "Setting TF_VAR_devops_pat, so Terraform azuredevops provider can authenticate to Azure DevOps"
    az account get-access-token --resource 499b84ac-1321-427f-aa17-267ca6975798 `
                                --query "accessToken" `
                                --output tsv `
                                | Set-Item env:TF_VAR_devops_pat
    Write-Debug "TF_VAR_devops_pat: "
    $env:TF_VAR_devops_pat -replace '.','*' | Write-Debug
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
