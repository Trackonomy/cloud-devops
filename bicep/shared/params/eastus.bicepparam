using '../main.bicep'

param location = 'eastus'
param env = 'shared'
param customer = 'unicorn'

//names
param acrRegistryName = 'acrtrkunieus'
param aksName = 'aks-trk-uni-shared-eastus'

// ssh access
param sshAksPubKeyName = 'ssh-aks-trk-uni-shared-eastus'
param sshAksPubKey = loadTextContent('../files/id_rsa.pub')

//pools 
param aksSystemPoolScale = 2
param aksSystemPoolSku = 'Standard_D4s_v3'
param aksSystemPoolMaxCount = 5
param aksUserPoolScale = 1
param aksUserPoolSku = 'Standard_D8s_v3'
param aksThirdPartyPoolScale = 1
param aksThirdPartyPoolSku =  'Standard_D8s_v3'

// key vaults
param uniEventsPpeKvName = 'kvunieventsppeeus2'
