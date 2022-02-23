param appName string
param region string
param environment string

var longName = '${appName}-${region}-${environment}'
var logicAppName = 'la-${longName}'

module networkDeployment 'network.bicep' = {
  name: 'networkDeployment'
  params: {
    longName: longName 
  }
}

module appServicePlanDeployment 'app-service-plan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    longName: longName
  }
}

module appInsightsDeployment 'app-insights.bicep' = {
  name: 'appInsightsDeployment'
  params: {
    longName: longName
    logicAppName: logicAppName
  }
}

module logicAppDeployment 'logic-app.bicep' = {
  name: 'logicAppDeployment'
  params: {
    appServicePlanName: appServicePlanDeployment.outputs.logicAppAppServicePlanName
    longName: longName
    logicAppName: logicAppName
    virtualNetworkName: networkDeployment.outputs.virtualNetworkName
    subnetName: networkDeployment.outputs.virtualNetworkSubnetName
    appInsightsName: appInsightsDeployment.outputs.appInsightsName
  }
}

module webApiDeployment 'web-api.bicep' = {
  name: 'webApiDeployment'
  params: {
    appServicePlanName: appServicePlanDeployment.outputs.webApiAppServicePlanName
    longName: longName
  }
}

output logicAppName string = logicAppDeployment.outputs.logicAppName
output logicAppUrl string = logicAppDeployment.outputs.logicAppUrl
output webApiName string = webApiDeployment.outputs.webApiName
output webApiUrl string = webApiDeployment.outputs.webApiUrl
