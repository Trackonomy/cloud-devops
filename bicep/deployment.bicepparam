// example settings
using 'deployment.bicep'
param location = 'eastus'
param env = 'sbx'
param customer  = 'unicorn'
param deployFunctions  = true 
param deploySB = true

// aks && acr
param aksName = 'aks-trk-sbx-unicorn'
param aksRegistryName = 'acr-trk-sbx-unicorn'
param linuxAdminUsername = 'Admin01'
param aksSshRSAPubliKey = 'aadsdsa'
param aksUserPoolScale = 1

// redis
param redisShardCount = 1
param redisBackupEnabled = true
param redisSkuCap = 1
param redisSkuName = 'Premium'

// asp
param funcAspName = 'ASP-functions-trk-sbx-unicorn'
param aspZoneRedundant = true

// functions
param filterFuncName = 'func-filter-iat-sbx-unicorn'
param cacheFuncName = 'func-cache-iat-sbx-unicorn'

// service bus
param numOfSBQueues = 2
param sbCapacity = 16
param sbNSName = 'sb-unicorn-sbx-iat'
param sbQueuesName = 'queue-unicorn-sbx-iat'
param sbSku = 'Premium'
param sbZoneRedundant = true
param getTapeeventsASPName = 'ASP-getTapeEvents-sbx'
param numOfGetTapeEventsServices = 2
param getTapeEventsServiceNames = ['iatgettapeeventsunisbx', 'healthgettapeeventsunisbx']
