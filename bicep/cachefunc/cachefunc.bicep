param cacheFuncLoc string = resourceGroup().location
param env string
param project string
param customer string = 'unicorn'
param cacheFuncName string = 'func-${project}-cache-${env}'
param cacheASPName string = 'ASP-${cacheFuncName}'

resource cacheAppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: cacheASPName
  location: cacheFuncLoc
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
    skuCapacity: {
      default: int
      elasticMaximum: int
      maximum: int
      minimum: int
      scaleType: 'string'
    }
    tier: 'string'
  }
  kind: 'string'
  extendedLocation: {
    name: 'string'
  }
  properties: {
    elasticScaleEnabled: true
    freeOfferExpirationTime: 'string'
    hostingEnvironmentProfile: {
      id: 'string'
    }
    hyperV: false 
    isSpot: false
    isXenon: false
    maximumElasticWorkerCount: 15
    perSiteScaling: bool
    reserved: bool
    spotExpirationTime: 'string'
    zoneRedundant: true
  }
}
