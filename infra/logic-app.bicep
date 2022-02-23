param longName string
param appServicePlanName string
param virtualNetworkName string
param subnetName string
param appInsightsName string
param logicAppName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: uniqueString('sa${longName}')
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        
      ]
      ipRules: [
        
      ]
    }
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
    }
  }
}

resource defaultBlobContainer 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = {
  name: '${storageAccount.name}/default'
}

resource defaultFileContainer 'Microsoft.Storage/storageAccounts/fileServices@2021-08-01' = {
  name: '${storageAccount.name}/default'
}

resource defaultQueueContainer 'Microsoft.Storage/storageAccounts/queueServices@2021-08-01' = {
  name: '${storageAccount.name}/default'
}

resource defaultTableContainer 'Microsoft.Storage/storageAccounts/tableServices@2021-08-01' = {
  name: '${storageAccount.name}/default'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' existing = {
  name: appServicePlanName
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  name: '${virtualNetworkName}/${subnetName}'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'

resource logicApp 'Microsoft.Web/sites@2021-03-01' = {
  name: logicAppName
  location: resourceGroup().location
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: appServicePlan.id
    httpsOnly: true
    virtualNetworkSubnetId: subnet.id
    siteConfig: {
      vnetRouteAllEnabled: true
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageConnectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: storageConnectionString
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: storageAccount.name
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~12'
        }
        {
          name: 'Workflows.WebhookRedirectHostUri'
          value: ''
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
      ]
    }
  }
}

resource logicAppVirtualNetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2021-03-01' = {
  name: '${logicApp.name}/${guid('default')}_default'
  properties: {
    vnetResourceId: virtualNetwork.id
    isSwift: true
  }
}

output logicAppName string = logicApp.name
output logicAppUrl string = logicApp.properties.defaultHostName
