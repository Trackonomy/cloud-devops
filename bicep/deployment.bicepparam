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
param aksSshRSAPubliKey = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6KFhVYR5XLSzkLZZcJCX7ABdD7SYahQOwDaZ4oNGHyQpI3lQJMzZngOR77YPRE5silIqCoDiSYNuEnfx2L3gGss35gkDVRm8jpJZsIk9SXWVSnZm5yEDke+8B+VdptvIkMPMhofKpZThu4R8nGDZ54hWRZdTWRf2PLgitOAyqhGxKqBI2vyz5hjMybSObX0eB9nkieHCspSKCuKusspT76JHxpJgUSazjB3Haa1M5ToOIiNtrOodO3Ndr6gzJl9rRU1kDjex9itssBBU4Y+XXLyyXzbOVrpgESTkRnByvP7i4G/eHiM3UdnzlscRmqB4UsfOVYEc0dx5Ilgpg+rmuYbdE+CfHWl0Kg775Uf3acQKO1rd59/8Kpng/GFVL5S+oBTCaBi8T3PkVLhfoiFhC1h+JZAvR4P9hl5NhCIugcl0nAAgAg/6Qy5tSwBNuMLbmUz/8h+y2pUgAagZIT/9MfzF0m/OGvbuHvNoz2a4Mcn026RdqrZCJpZPrZ/Xt/lnNyV0ifVw50+iImv/Y7omvJ2eijeGO3ZDurpkAhXQoaoXl1Nv/uREE9w1QSpMPpEBq/RymHTzXNlLbzYY2pBFBmwfvDBcydT0ByKn10HCpdM+Iv04U7ZJiD8abhTWKYDpAc3yvwOjNZzHVwf0IvPdpegU0RkZGJ6pYrKKrrC525Q== kinatra@TRCK-Artem'
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
