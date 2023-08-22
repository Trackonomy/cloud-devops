// general
param location string
param env string
param customer string = 'unicorn'

param deployFunctions bool = true 
param deploySB bool = true
param deployGetTapeeventsAppService bool = true
param deployCache bool = true
param deployACRAndAKS bool = true

// aks && acr
param aksName string = 'aks-${customer}-${env}-${location}'
param aksRegistryName string = 'acr${customer}${env}'
param linuxAdminUsername string = 'Admin01'
param aksSshRSAPublicKey string = ''
param aksUserPoolScale int = 3

// redis
@description('Number of shards for redis cache.')
param redisShardCount int = 0
@description('Enable RDB backup. Must be Premium SKU!')
param redisBackupEnabled bool = false
@allowed([0,1,2,3,4,5,6])
@description('SKU Capacity. 0-6 for basic/standard, 0-4 for premium. Reference: https://azure.microsoft.com/en-us/pricing/details/cache/')
param redisSkuCap int
@allowed(['Basic', 'Premium', 'Standard'])
param redisSkuName string

// functions
@description('Name of app service plan which will be used for cache function')
param funcAspName string = 'ASP-func-${customer}-${env}-${location}'
@description('If app service plans should be zone-redundant')
param aspZoneRedundant bool = false
@description('Name of filter function')
param filterFuncName string = 'func-filter-${customer}-${env}-${location}'
@description('Name of cache function')
param cacheFuncName string = 'func-filter-${customer}-${env}-${location}'

// service bus
@description('Number of service bus queues')
@allowed([1, 2])
param numOfSBQueues int = 2
@description('Capacity of service bus in processing units.')
@allowed([1, 2, 4, 8, 16])
param sbCapacity int = 16
@description('Name of service bus namespace')
param sbNSName string = 'svbus-trk-${customer}-${env}-${location}'
@description('Name of service bus queues. Queues names will be {name}-{number}.')
param sbQueuesName string = 'events-${customer}-${env}-${location}'
@allowed(['Basic', 'Premium', 'Standard'])
@description('Sku of service bus.')
param sbSku string = 'Standard'
@description('If service bus is zone-redundant')
param sbZoneRedundant bool = false

// app service gettapeevents
@description('Homw many getTapeEvents Service Apps to deploy')
@allowed([1,2])
param numOfGetTapeEventsServices int = 2
@description('Array of app service names that will be created. Values should be the same as num of services to remove confusion.')
param getTapeEventsServiceNames array = ['trk${customer}${env}tapeevent', 'trkiat${customer}${env}tapeevent']
@description('Array of ASP names that will be created. Values should be the same as num of services to remove confusion.')
param getTapeEventsASPNames array = ['ASP-trk${customer}${env}tapeevent', 'ASP-trkiat${customer}${env}tapeevent']


module aks 'aks/aks.bicep' = if (deployACRAndAKS) {
  name: 'deployAks'
  params: {
    aksName: aksName
    env: env
    location: location
    customer: customer
    linuxAdminUsername: linuxAdminUsername
    sshRSAPublicKey: aksSshRSAPublicKey
    userPoolScale: aksUserPoolScale
  }
}

module acr 'aks/acr.bicep' = if(deployACRAndAKS) {
  name: 'deployAcrAndCreateRole'
  params: {
    aksPrincipalId: aks.outputs.clusterPrincipalID
    env: env
    customer: customer
    location: location
    registryName: aksRegistryName
  }
  dependsOn: [aks]
}

module cache 'caching/cache.bicep' =  if (deployCache) {
  name: 'deployRedisCache'
  params: {
    env: env
    customer: customer
    location: location
    skuCap: redisSkuCap
    skuName: redisSkuName
    backupEnabled: redisSkuName == 'Basic' ? false : redisBackupEnabled
    shardCount: redisShardCount
  }
}

module func_asp 'functions/funcasp.bicep' = if (deployFunctions) {
  name: 'deployFunctionAppServicePlan'
  params: {
    aspName: funcAspName
    customer: customer
    env: env
    zoneredundant: aspZoneRedundant
    location: location
  }
}

module filterFunction 'functions/filterfunc.bicep' = if (deployFunctions) {
  name: 'deployFilterFunction'
  dependsOn: [func_asp]
  params: {
    aspId: func_asp.outputs.aspId
    env: env
    location: location
    customer: customer
    filterFuncName: filterFuncName
  }
}
module cacheFunction 'functions/cachefunc.bicep' = if (deployFunctions) {
  name: 'deployCacheFunction'
  dependsOn: [func_asp]
  params: {
    aspId: func_asp.outputs.aspId
    env: env
    location: location
    customer: customer
    cacheFuncName: cacheFuncName
  }
}

module serviceBus 'servicebus/servicebus.bicep' = if (deploySB) {
  name: 'deployServicebus'
  params: {
    env: env
    location: location
    customer: customer
    numOfQueues: numOfSBQueues
    sbCapacity: sbCapacity
    sbNamespaceName: sbNSName
    sbQueuesName: sbQueuesName
    sbSku: sbSku
    zoneRedundant: sbZoneRedundant
  }
}

module gettapeeventsAsp 'appservice/site-asp.bicep' = [ for i in range (0, numOfGetTapeEventsServices) : if(deployGetTapeeventsAppService) {
  name: 'deploySiteAppServicePlan'
  params: {
    env: env
    location: location
    customer: customer
    aspName: getTapeEventsASPNames[i]
  }
}]

module gettapeeventsAppServices 'appservice/appservice.bicep' =  [ for i in range(0, numOfGetTapeEventsServices): if(deployGetTapeeventsAppService) {
  name: 'deploy${getTapeEventsServiceNames[i]}'
  params: {
    location: location
    appServiceName: getTapeEventsServiceNames[i]
    aspId: gettapeeventsAsp[i].outputs.aspId
    customer: customer
    env: env
  }
}]
