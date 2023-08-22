param env string
param customer string
param location string = resourceGroup().location
param zoneredundant bool
param aspName string

resource functionsAppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: aspName
  location: location
  tags: {
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

output aspId string = functionsAppServicePlan.id
