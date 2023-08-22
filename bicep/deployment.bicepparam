// example settings
using 'deployment.bicep'
param location = 'eastus'
param env = 'sbx'
param customer  = 'unicorn'
param deployFunctions = true 
param deploySB = true
param deployGetTapeeventsAppService = true
param deployCache = true
param deployACRAndAKS = true

// aks && acr
param aksName = 'aks-trk-sbx-unicorn'
param aksRegistryName = 'acrtrksbxunicorn'
param linuxAdminUsername = 'Admin01'
param aksSshRSAPublicKey = ''
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
param getTapeEventsASPNames = ['ASP-getTapeEvents-sbx-iat', 'ASP-getTapeEvents-sbx-health']
param numOfGetTapeEventsServices = 2
param getTapeEventsServiceNames = ['iatgettapeeventsunisbx', 'healthgettapeeventsunisbx']
