param longName string

resource logicAppAppServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: 'asp-logicApp-${longName}'
  location: resourceGroup().location
  sku: {
    name: 'WS1'
    tier: 'WorkflowStandard'
    size: 'WS1'
    family: 'WS'
    capacity: 1
  }
}

resource webApiAppServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: 'asp-webApi-${longName}'
  location: resourceGroup().location
  kind: 'web'
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
}

output logicAppAppServicePlanName string = logicAppAppServicePlan.name
output webApiAppServicePlanName string = webApiAppServicePlan.name
