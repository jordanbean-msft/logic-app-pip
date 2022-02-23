param longName string
param appServicePlanName string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' existing = {
  name: appServicePlanName
}

resource webApi 'Microsoft.Web/sites@2021-03-01' = {
  name: 'wa-${longName}'
  location: resourceGroup().location
  kind: 'app'
  properties: {
    enabled: true
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      ipSecurityRestrictions: [
        {
        ipAddress: '10.0.0.0/32'
        action: 'Allow'
        priority: 100
        name: 'Allow Logic App IP address'
        description: 'Allow Logic App IP address'
      }
    ]
    }
  }
}

output webApiName string = webApi.name
output webApiUrl string = webApi.properties.defaultHostName
