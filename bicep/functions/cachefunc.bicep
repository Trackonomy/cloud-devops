param location string = resourceGroup().location
param env string
param customer string = 'unicorn'
param aspId string
param cacheFuncName string
param cacheFuncStorageAccountName string = cacheFuncName
param cacheFuncAppInsightsName string = cacheFuncName 
var runtime = 'node'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: cacheFuncStorageAccountName
  location: location
  sku: {
    name: cacheFuncStorageAccountName
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

resource cacheFunc 'Microsoft.Web/sites@2022-09-01' = {
  location: location
  name: cacheFuncName
  kind: 'functionapp'
  tags: {
    env: env
    customer: customer
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: aspId
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${cacheFuncStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${cacheFuncStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(cacheFuncName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: cacheFuncAppInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtime
        }
      ]
    }
  }
}

resource cacheFuncAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: cacheFuncAppInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}
