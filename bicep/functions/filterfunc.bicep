param location string = resourceGroup().location
param env string
param customer string = 'unicorn'
param aspId string
param filterFuncName string

var runtime = 'node'

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
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtime
        }
      ]
    }
  }
}
