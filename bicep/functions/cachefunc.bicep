param location string = resourceGroup().location
param env string
param customer string = 'unicorn'
param aspId string
param cacheFuncName string

var runtime = 'node'

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
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtime
        }
      ]
    }
  }
}
