param location string = resourceGroup().location
param env string
param customer string = 'unicorn'
param aspId string
param filterFuncName string
param filterFuncStorageAccountName string = 'filterfuncstacc${substring(uniqueString(resourceGroup().id), 0, 6)}'
param filterFuncAppInsightsName string = filterFuncName
var runtime = 'node'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: filterFuncStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

resource filterFunc 'Microsoft.Web/sites@2022-09-01' = {
  location: location
  name: filterFuncName
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
          value: 'DefaultEndpointsProtocol=https;AccountName=${filterFuncStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${filterFuncStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(filterFuncName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: filterFuncAppInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtime
        }
      ]
    }
  }
}

resource filterFuncAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: filterFuncAppInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}
