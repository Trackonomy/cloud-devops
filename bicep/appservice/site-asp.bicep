param env string
param customer string
param location string = resourceGroup().location
param aspName string
param skuName string = 'P3V3'
param skuTier string = 'PremiumV3'


resource siteAppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: aspName
  location: location
  tags: {
    env: env
    customer: customer
  }
  sku: {
    name: skuName
    tier: skuTier
    capacity: 1
    skuCapacity: {
      default: 1
      elasticMaximum: 1
      maximum: 1
      minimum: 1
    }
  }
  properties: {
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    zoneRedundant: false
  }
  kind: 'linux'
}

output aspId string = siteAppServicePlan.id
