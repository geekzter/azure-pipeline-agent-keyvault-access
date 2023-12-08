resource azuredevops_agent_pool pool {
  name                         = var.name
  auto_provision               = false

  lifecycle {
    ignore_changes             = [
      name
    ]
  }
}
resource azuredevops_agent_queue pool {
  project_id                   = local.project_id
  agent_pool_id                = azuredevops_agent_pool.pool.id
}
resource azuredevops_pipeline_authorization pool {
  project_id                   = local.project_id
  resource_id                  = azuredevops_agent_queue.pool.id
  type                         = "queue"
}