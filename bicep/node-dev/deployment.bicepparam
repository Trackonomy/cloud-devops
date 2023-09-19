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
//# Create an SSH key pair using Azure CLI
//az sshkey create --name "mySSHKey" --resource-group "myResourceGroup"
//# Create an SSH key pair using ssh-keygen
//ssh-keygen -t rsa -b 4096
param aksSshRSAPublicKey = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCoQzf362yad8edkHZ6TFwyoIIvlvAxt0NVbiFsOyIW0BlWkqPJgS8aFBgb+p2EakP0S9Z/4pDlkPH2bKhie4noc7qr7VK2J5tpqHmnZyUCIpzcbvFDMNkbooxEpXFHx3evAUH/0nUXv4A+AoYadgrUiFC4lMKiTF6Utj1CYcM0x2laIViiGP0Rl46mfH36eehVqxnUJjgz101RoL8vAeg+ty6aUnx17+cp7kBRqB1EBkGXixlYYXrs258nwLpRTyaMVW1rrSn6sv1vBMJrTX3/BhdeiH/C0u/3CsU6kqiemG/t+aGERNis5Lr0X9Wz4AP6Vaj2UDL7j60pYwPlhQER/wNsi5lCmbvC/jJ6MtqIIQQjb4mq8us83yaxjklELAMKxFqk+lluoKSFH41guyavf7zCG/5yU1SptgNk5BQR8j+x526n7yNLEf40sZoc27LnNPadlNsC1yy7/XTws98O2/+cAbZgkgpWVEMnrIt2+7f21oQOR7dal1tvH18DPI0='
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
