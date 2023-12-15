resource azuredevops_agent_pool pool {
  name                         = var.repo_name
  auto_provision               = false

  lifecycle {
    ignore_changes             = [
      name
    ]
  }

  count                        = var.create_pool ? 1 : 0
}
resource azuredevops_agent_queue pool {
  project_id                   = local.project_id
  agent_pool_id                = azuredevops_agent_pool.pool.0.id

  count                        = var.create_pool ? 1 : 0
}
resource azuredevops_pipeline_authorization pool {
  project_id                   = local.project_id
  resource_id                  = azuredevops_agent_queue.pool.0.id
  type                         = "queue"

  count                        = var.create_pool ? 1 : 0
}