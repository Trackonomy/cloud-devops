param aksName string
param location string
param aksRegistryName string
param env string
param customer string = 'unicorn'
param linuxAdminUsername string = 'Admin01'
param aksSshRSAPubliKey string
param aksUserPoolScale int = 3

param redisShardCount int
param redisBackupEnabled bool
param redisSkuCap int

@allowed(['Basic', 'Premium', 'Standard'])
param redisSkuName string

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
