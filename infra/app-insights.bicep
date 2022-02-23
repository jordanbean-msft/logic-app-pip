param longName string
param logicAppName string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ai-${longName}'
  location: resourceGroup().location
  kind: 'web'
  tags: {
    'hidden-link:/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${logicAppName}': 'Resource'
  }
  properties: {
    Application_Type: 'web'
    IngestionMode: 'ApplicationInsights'
  }
}

output appInsightsName string = appInsights.name
