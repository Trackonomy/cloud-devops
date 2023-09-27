using '../main.bicep'

param location = 'eastus2'
param env = 'shared'
param customer = 'unicorn'

//names
param acrRegistryName = 'acrtrkunieus2'
param aksName = 'aks-trk-uni-shared-eastus2'

// ssh access
param sshAksPubKeyName = 'ssh-aks-trk-uni-shared-eastus2'
param sshAksPubKey = loadTextContent('../files/id_rsa.pub')

//pools 
param aksSystemPoolScale = 2
param aksSystemPoolSku = 'Standard_D4s_v3'
param aksUserPoolScale = 1
param aksUserPoolSku = 'Standard_D8s_v3'
param aksThirdPartyPoolScale = 1
param aksThirdPartyPoolSku =  'Standard_D8s_v3'
