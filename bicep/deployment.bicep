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
param aksName string
param aksRegistryName string
param linuxAdminUsername string = 'Admin01'
param aksSshRSAPubliKey string
param aksUserPoolScale int = 3

// redis
param redisShardCount int
param redisBackupEnabled bool
param redisSkuCap int
@allowed(['Basic', 'Premium', 'Standard'])
param redisSkuName string

// functions
param funcAspName string
param aspZoneRedundant bool
param filterFuncName string
param cacheFuncName string

// service bus
param numOfSBQueues int = 2
@allowed([1, 2, 4, 8, 16])
param sbCapacity int = 16
param sbNSName string
param sbQueuesName string
@allowed(['Basic', 'Premium', 'Standard'])
param sbSku string
param sbZoneRedundant bool

// app service gettapeevents
param numOfGetTapeEventsServices int = 2
@description('Array of app service names that will be created. Values should be the same as num of services to remove confusion.')
param getTapeEventsServiceNames array = []
param getTapeeventsASPName string

module aks 'aks/aks.bicep' = if (deployACRAndAKS) {
  name: 'deployAks'
  params: {
    aksName: aksName
    env: env
    location: location
    customer: customer
    linuxAdminUsername: linuxAdminUsername
    sshRSAPublicKey: aksSshRSAPubliKey
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

module func_asp 'functions/asp.bicep' = if (deployFunctions) {
  name: 'deployFunctionsAppServicePlan'
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

module gettapeeventsAsp 'appservice/site-asp.bicep' = if (deployGetTapeeventsAppService) {
  name: 'deploySiteAppServicePlan'
  params: {
    env: env
    location: location
    customer: customer
    aspName: getTapeeventsASPName
  }
}

module gettapeeventsAppServices 'appservice/appservice.bicep' =  [ for i in range(0, numOfGetTapeEventsServices): if(deployGetTapeeventsAppService) {
  name: 'deploy${getTapeEventsServiceNames[i]}'
  params: {
    location: location
    appServiceName: getTapeEventsServiceNames[i]
    aspId: gettapeeventsAsp.outputs.aspId
    customer: customer
    env: env
  }
}]
