// root properties
param cacheLoc string = resourceGroup().location
param env string
param project string
param customer string = 'unicorn'
param cacheName string = 'redis-${project}-${env}'
@description('Availability zones')
param zones array = []

// general properties settings
param nonSSL bool = false
@allowed([0,1,2,3,4,5,6])
@description('SKU Capacity. 0-6 for basic/standard, 0-4 for premium')
param skuCap int
@allowed(['Basic', 'Premium', 'Standard'])
param skuName string
@allowed(
  ['4.0', '6.0', 'latest']
)
param version string = '6.0'
param shardCount int = 0

// identity properties
@description('If the identity is enabled. In case it is true, please provide identityObj param')
param identityEnabled bool = false
@description('Identity object. To use it, enable first identity by setting param identityEnabled')
param identityObj object = {}
var identity = identityEnabled ? identityObj : {
  type: 'None'
}

// backup properties
@description('Enable RDB backup. Must be Premium SKU!')
param backupEnabled bool = false
param storageName string = ''

// memory properties
@description('maxfragmentationmemory-reserved in MB')
param mfragmmemoryr string = '1330'
@allowed(['volatile-lru', 'allkeys-lru', 'volatile-random', 'allkeys-random', 'volatile-ttl', 'noeviction', 'volatile-lfu', 'allkeys-lfu'])
param mmemorypolicy string = 'volatile-lru'
@description('maxmemory-reserved in MB')
param mmemoryres string = '1330'

var cacheProperties = {
  enableNonSslPort: nonSSL
  minimumTlsVersion: '1.2'
  redisVersion: version
  
  sku : {
    capacity: skuCap
    name: skuName
    family: skuName == 'Premium' ? 'P' : 'C'
  }
  
  redisConfiguration: backupEnabled && skuName == 'Premium' ? { // if RDB BACKUP (must be premium sku)
    'rdb-backup-enabled': 'true'
    'rdb-backup-frequency': '1440'
    'rdb-storage-connection-string': 'DefaultEndpointsProtocol=https;AccountName=${redisstoragerdbbackup.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${redisstoragerdbbackup.listKeys().keys[0].value}'
    'maxfragmentationmemory-reserved': mfragmmemoryr
    'maxmemory-policy': mmemorypolicy
    'maxmemory-reserved': mmemoryres
  } : { // if NO backup
    'maxfragmentationmemory-reserved': mfragmmemoryr
    'maxmemory-policy': mmemorypolicy
    'maxmemory-reserved': mmemoryres
  }
}
resource rediscache 'Microsoft.Cache/redis@2022-06-01' = {
  location: cacheLoc
  name: cacheName
  tags: {
    project: project
    env: env
    customer: customer
  }
  identity: identity
  zones: zones
  properties: skuName != 'Basic' ? union(cacheProperties, {shardCount: shardCount}) : cacheProperties // on basic sku we cannot specify shardCount
}

resource redispatches 'Microsoft.Cache/redis/patchSchedules@2023-04-01' = {
  name: 'default'
  parent: rediscache
  properties: {
    scheduleEntries: [
      {
        dayOfWeek: 'Everyday'
        maintenanceWindow: '5H'
        startHourUtc: 0
      }
    ]
  }
}

resource redisstoragerdbbackup 'Microsoft.Storage/storageAccounts@2022-09-01' = if (backupEnabled) {
  location: cacheLoc
  name: storageName == '' ? 'staccredisback${substring(uniqueString(resourceGroup().id), 0, 5)}' : storageName
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: true
  }
  tags: {
    project: project
    env: env
    customer: customer
    backup: 'backup'
  }
}
