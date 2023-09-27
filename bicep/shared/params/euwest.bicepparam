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
param aksUserPoolSku = 'Standard_D8s_v3'
param aksThirdPartyPoolScale = 1
param aksThirdPartyPoolSku =  'Standard_D8s_v3'

//key vaults
param uniEventsPpeKvName = 'kvunieventsppeweu'
