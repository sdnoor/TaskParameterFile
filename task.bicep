param environmentType string
param projectName string
param projectShortName string
param location string = 'eastus2'
// param storageAccountName string = 'sto${uniqueString(resourceGroup().id)}${environmentType}'
param storageAccountSkuName string
param storageAccountSkuKind string
param storageAccountSkuTier string
// param appServicePlanName string = 'sp-BICEPTEMPLATE-${environmentType}'
param appServicePlanSkuName string
// param webAppName string = 'webapp-BICEPTEMPLATE-${environmentType}'
// param functionAppName string = 'func-BICEPTEMPLATE-${environmentType}'

param timeZone string


var appServicePlanName = 'sp-${projectName}-${environmentType}'
var webAppName  = 'webapp-${projectName}-${environmentType}'
var functionAppName  = 'func-${projectName}-${environmentType}'
var storageAccountName  = 'sto${projectShortName}${environmentType}'


resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: { 
    name: storageAccountSkuName 
  }
  kind: storageAccountSkuKind
  properties: {
    accessTier: storageAccountSkuTier
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  properties: {
   serverFarmId: appServicePlan.id
   httpsOnly: true 
  }
}

resource azureFunction 'Microsoft.Web/sites@2020-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsDashboard'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'WEBSITE_TIME_ZONE'
          value: timeZone
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
    }
  }
}


