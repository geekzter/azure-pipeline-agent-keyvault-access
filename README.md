# Sourcing Azure Pipeline variables from a private Azure Key Vault

This repo demonstrates how to configure a Key Vault for private access. That is, constrain access to Azure devOps and your Self-hosted agents. It uses Terraform with the [azuread](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs), [azuredevops](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs) and [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) providers to create an end-to-end sample.

Below, the key elements to allow access to an Azure Key Vault are explained.

## Link an Azure Pipelines Variable Group to a private Azure Key Vault

Azure Pipelines provides the ability to [integrate an Azure Key Vault with Variable Groups](https://learn.microsoft.com/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault). A Key Vault that is used as a Variable Group can be accessed:

- From Azure DevOps, during Variable Group configuration time
- From a Self-hosted agent, during Pipeline job runtime

### Configure inbound access from Azure DevOps

[This page](https://learn.microsoft.com/azure/devops/organizations/security/allow-list-ip-url?view=azure-devops&tabs=IP-V4#inbound-connections) lists IP ranges for Azure DevOps geographies. You can find the [geography](https://learn.microsoft.com/azure/devops/organizations/security/data-protection?view=azure-devops#data-residency-and-sovereignty) used by your Azure DevOps organization using [this instruction](https://learn.microsoft.com/azure/devops/organizations/accounts/change-organization-location?view=azure-devops#find-your-organization-geography).

By default, this repo will allow inbound access from all Azure DevOps geographies (including ExpressRoute). To override the default and constrain inbound access to a single geography, specify:

```hcl
azdo_geography = 'us' 
```

See [variables.tf](terraform/variables.tf) for a list of possible Terraform variables.

### Configure inbound access from Self-hosted Agents

To have the ability to access a private Key Vault from an Azure Pipelines agent, you'll need to use a Self-hosted or Scale set agent. Microsoft Hosted agents are not in the Key Vault [trusted services list](https://learn.microsoft.com/azure/key-vault/general/overview-vnet-service-endpoints#trusted-services) (no generic compute service is).

To provide [line of sight](https://learn.microsoft.com/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=yaml%2Cbrowser#communication-to-deploy-to-target-servers) to a Key Vault. You need to configure a [private endpoint](https://learn.microsoft.com/azure/key-vault/general/private-link-service?tabs=portal) for the Key Vault.

## Run the KeyVault task pre-job

If you omit granting Azure DevOps inbound access to your private Key Vault, Variable Group integration won't work. You can still populate Pipeline variables from a Key Vault by specifying the `runAsPreJob: true` property on the [KeyVault task](https://learn.microsoft.com/azure/devops/pipelines/tasks/reference/azure-key-vault-v2?view=azure-pipelines):


```yaml
  - task: AzureKeyVault@2
    displayName: 'AzureKeyVault@2: Access Key Vault pre-job'
    inputs:
      azureSubscription: '$(serviceConnectionName)'
      keyVaultName: $(keyVaultName)
      secretsFilter: '*'
      runAsPreJob: true
```

This will inject the KeyVault task before your tasks run, the same way as a Variable Group would.

### Key Vault Firewall messages

The below messages mean the Azure Key Vault firewall blocks access:

```
Public network access is disabled and request is not from a trusted service nor via an approved private link.
```

Public access has been disabled.

```
Request was not allowed by NSP rules and the client address is not authorized and caller was ignored because bypass is set to None
Client address: <x.x.x.x>
```

Public access has been enabled. The client IP address has not been added to the Key Vault firewall.

```
TF400898: An Internal Error Occurred. Activity Id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.
```

This error can occur when adding a Key Vault has Variable Group and Azure DevOps has not been allowed inbound access.
