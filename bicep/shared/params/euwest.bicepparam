using '../main.bicep'

param location = 'westeurope'
param env = 'shared'
param customer = 'unicorn'

//names
param acrRegistryName = 'acrtrkuniweu'
param aksName = 'aks-trk-uni-shared-westeu'

// ssh access
param sshAksPubKeyName = 'ssh-aks-trk-uni-shared-westeu'
param sshAksPubKey = loadTextContent('../files/id_rsa.pub')

//pools 
param aksSystemPoolScale = 2
param aksSystemPoolSku = 'Standard_D4s_v3'
param aksUserPoolScale = 1
param aksUserPoolSku = 'Standard_D8as_v5'
param aksThirdPartyPoolScale = 1
param aksThirdPartyPoolSku =  'Standard_D8as_v5' //similar to D8s_v3 (8 cores and 32 gb of ram)

//key vaults
param uniEventsPpeKvName = 'kvunieventsppeweu'
