// general
param location string
param env string
param customer string = 'unicorn'
param deployFunctions bool = true 

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

// asp
param aspName string
param aspZoneRedundant bool

// functions
param filterFuncName string
param cacheFuncName string

module aks 'aks/aks.bicep' = {
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
module acr 'aks/acr.bicep' = {
  name: 'deploy Acr and create role'
  params: {
    aksPrincipalId: aks.outputs.clusterPrincipalID
    env: env
    customer: customer
    location: location
    registryName: aksRegistryName
  }
  dependsOn: [aks]
}

module cache 'caching/cache.bicep' = {
  name: 'deploy Redis cache'
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

module asp 'functions/asp.bicep' = if (deployFunctions) {
  name: 'deploy App Service Plan'
  params: {
    aspName: aspName
    customer: customer
    env: env
    zoneredundant: aspZoneRedundant
    location: location
  }
}

module filterFunction 'functions/filterfunc.bicep' = if (deployFunctions) {
  name: 'deploy Filter Function'
  dependsOn: [asp]
  params: {
    aspId: asp.outputs.aspId
    env: env
    location: location
    customer: customer
    filterFuncName: filterFuncName
  }
}
module cacheFunction 'functions/cachefunc.bicep' = if (deployFunctions) {
  name: 'deploy Cache Function'
  dependsOn: [asp]
  params: {
    aspId: asp.outputs.aspId
    env: env
    location: location
    customer: customer
    cacheFuncName: cacheFuncName
  }
}
