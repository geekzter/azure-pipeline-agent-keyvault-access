data azuread_client_config current {}
data azurerm_subscription current {}

data http terraform_ip_address {
# Get public IP address of the machine running this terraform template
  url                          = "https://ipinfo.io/ip"
}
data http terraform_ip_prefix {
# Get public IP prefix of the machine running this terraform template
  url                          = "https://stat.ripe.net/data/network-info/data.json?resource=${chomp(data.http.terraform_ip_address.response_body)}"
}

# Random resource suffix, this will prevent name collisions when creating resources in parallel
resource random_string suffix {
  length                       = 4
  upper                        = false
  lower                        = true
  numeric                      = false
  special                      = false
}

resource random_string password {
  length                       = 12
  upper                        = true
  lower                        = true
  numeric                      = true
  special                      = true
# override_special             = "!@#$%&*()-_=+[]{}<>:?" # default
# Avoid characters that may cause shell scripts to break
  override_special             = "." 
}

locals {
  allow_ip_ranges              = sort(distinct(concat([for range in local.azdo_geography_ip_ranges : cidrsubnet(range,0,0)],tolist([local.terraform_ip_address])))) # Make sure ranges have correct base address
  azdo_org_url                 = replace(var.azdo_org_url,"/\\/$/","")
  azdo_geography_ip_ranges     = var.azdo_geography != null ? local.geographies[lower(var.azdo_geography)] : flatten(values(local.geographies))
  environment_variables        = var.create_agent ? {
    PIPELINE_DEMO_AGENT_LOCATION           = var.azure_location
    PIPELINE_DEMO_AGENT_OUTBOUND_IP        = module.network.0.outbound_ip_address
    PIPELINE_DEMO_AGENT_SUBNET_ID          = module.network.0.self_hosted_agents_subnet_id
    PIPELINE_DEMO_AGENT_VIRTUAL_NETWORK_ID = module.network.0.virtual_network_id
    PIPELINE_DEMO_APPLICATION_NAME         = var.application_name
    PIPELINE_DEMO_APPLICATION_OWNER        = var.application_owner
    # PIPELINE_DEMO_KEY_VAULT_ID             = module.key_vault.key_vault_id
    # PIPELINE_DEMO_KEY_VAULT_NAME           = module.key_vault.key_vault_name
    PIPELINE_DEMO_RESOURCE_GROUP_ID        = azurerm_resource_group.rg.id
    PIPELINE_DEMO_RESOURCE_GROUP_NAME      = azurerm_resource_group.rg.name
    PIPELINE_DEMO_RESOURCE_PREFIX          = var.resource_prefix
    PIPELINE_DEMO_RESOURCE_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
  } : {}
  initial_suffix               = var.resource_suffix != null && var.resource_suffix != "" ? lower(var.resource_suffix) : random_string.suffix.result
  initial_tags                 = merge(
    {
      application              = var.application_name
      githubRepo               = "https://github.com/geekzter/azure-pipeline-agent-keyvault-access"
      owner                    = var.application_owner
      provisioner              = "terraform"
      provisionerClientId      = data.azuread_client_config.current.client_id
      provisionerObjectId      = data.azuread_client_config.current.object_id
      repository               = "azure-pipelines-container-agent"
      runId                    = var.run_id
      suffix                   = local.initial_suffix
      workspace                = terraform.workspace
    },
    var.azure_tags
  )
  key_vault_name               = terraform.workspace == "default" ? "variablegroup${local.suffix}" : "variablegroup${terraform.workspace}${local.suffix}"
  notes                        = "Variable group service connection ${local.key_vault_name}. Managed by Terraform: https://github.com/geekzter/azure-pipeline-agent-keyvault-access"
  password                     = ".Az9${random_string.password.result}"
  pipeline_agent_name          = "${var.resource_prefix}-keyvault-${terraform.workspace}"
  suffix                       = azurerm_resource_group.rg.tags["suffix"] # Ignores updates to var.resource_suffix
  tags                         = azurerm_resource_group.rg.tags           # Ignores updates to var.resource_suffix
  terraform_ip_address         = chomp(data.http.terraform_ip_address.response_body)
  terraform_ip_prefix          = jsondecode(chomp(data.http.terraform_ip_prefix.response_body)).data.prefix
}

resource azurerm_resource_group rg {
  name                         = terraform.workspace == "default" ? "${var.resource_prefix}-private-keyvault-${local.initial_suffix}" : "${var.resource_prefix}-${terraform.workspace}-keyvault-variable-group-${local.initial_suffix}"
  location                     = var.azure_location

  tags                         = local.initial_tags

  lifecycle {
    ignore_changes             = [
      location,
      name,
      tags["suffix"]
    ]
  }  
}

resource local_file verify_keyvault_access_script {
  content                      = templatefile("${path.root}/../scripts/templates/verify_keyvault_access.template.ps1",
  {
    keyVaultName               = module.key_vault.key_vault_name
    resourceGroup              = azurerm_resource_group.rg.name
    subscriptionId             = data.azurerm_subscription.current.subscription_id
  })
  filename                     = "${path.root}/../data/${terraform.workspace}/verify_keyvault_access.ps1"
}

resource local_file verify_keyvault_remote_access_script {
  content                      = templatefile("${path.root}/../scripts/templates/verify_keyvault_remote_access.template.ps1",
  {
    agentName                  = local.pipeline_agent_name
    bastionId                  = module.network.0.bastion_id
    bastionName                = module.network.0.bastion_name
    identityObjectId           = azurerm_user_assigned_identity.agents.principal_id
    keyVaultName               = module.key_vault.key_vault_name
    resourceGroup              = azurerm_resource_group.rg.name
    sshPrivateKey              = var.azure_agent_ssh_private_key
    subscriptionId             = data.azurerm_subscription.current.subscription_id
    userName                   = var.azure_agent_user_name
    vmId                       = var.create_azdo_resources && var.create_agent ? module.self_hosted_linux_agents.vm_id : null
  })
  filename                     = "${path.root}/../data/${terraform.workspace}/verify_keyvault_remote_access.ps1"

  count                        = var.create_agent && var.create_azure_bastion ? 1 : 0
}
