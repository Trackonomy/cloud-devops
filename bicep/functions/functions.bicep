param location string = resourceGroup().location
param env string
param project string
param customer string = 'unicorn'
param zoneredundant string
param aspName string = 'ASP-${project}-${env}'
param cacheFuncName string = 'func-${project}-cache-${env}'
param filterFuncName string = 'func-${project}-filter-${env}'

var runtime = 'node'


resource functionsAppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: aspName
  location: location
  tags: {
    project: project
    env: env
    customer: customer
  }
  sku: {
    capacity: 6
    family: 'EP'
    name: 'EP2'
    size: 'EP2'
  }
  properties: {
    elasticScaleEnabled: true
    hyperV: false 
    isSpot: false
    isXenon: false
    maximumElasticWorkerCount: 15
    zoneRedundant: zoneredundant
  }
}

resource cacheFunc 'Microsoft.Web/sites@2022-09-01' = {
  location: location
  name: cacheFuncName
  dependsOn: [
    functionsAppServicePlan
  ]
  kind: 'functionapp'
  tags: {
    project: project
    env: env
    customer: customer
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: functionsAppServicePlan.id
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

resource filterFunc 'Microsoft.Web/sites@2022-09-01' = {
  location: location
  name: filterFuncName
  dependsOn: [
    functionsAppServicePlan
  ]
  kind: 'functionapp'
  tags: {
    project: project
    env: env
    customer: customer
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: functionsAppServicePlan.id
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
