param location string
param customer string = 'unicorn'
param env string = 'shared'

// global acr params
@description('Name of the global acr')
param acrRegistryName string

// global ssh params
@description('Name of the public key for aks')
param sshAksPubKeyName string

@description('Public Key SSH to access VM')
param sshAksPubKey string

// global aks params for dev/stage/ppe environments
@description('Name of the aks')
param aksName string

@description('AKS System pool scale')
param aksSystemPoolScale int

@description('System pool max count')
param aksSystemPoolMaxCount int

@description('AKS User Pool Scale')
param aksUserPoolScale int

@description('AKS 3rd party pool scale')
param aksThirdPartyPoolScale int

@description('AKS System pool SKU')
param aksSystemPoolSku string

@description('AKS User pool SKU')
param aksUserPoolSku string

@description('AKS 3rd party pool SKU')
param aksThirdPartyPoolSku string

@description('Uni events key vault name for PPE env')
param uniEventsPpeKvName string

module global_acr 'acr.bicep' = {
  name: 'DeployGlobalAcr'
  params: {
    location: location
    env: env
    customer: customer
    registryName: acrRegistryName
  }
}


module global_pubkey 'akskeyssh.bicep' = {
  name: 'DeployKubernetesSshKey'
  params: {
    location: location
    env: env
    customer: customer
    sshAksPubKeyName: sshAksPubKeyName
    pubKey: sshAksPubKey
  }
}

module global_aks 'aks.bicep' = {
  name: 'DeployGlobalAks'
  params: {
    location: location
    env: env
    customer: customer
    aksName: aksName
    systemPoolScale: aksSystemPoolScale
    userPoolScale: aksUserPoolScale
    thirdPartyPoolScale: aksThirdPartyPoolScale
    systemPoolSKU: aksSystemPoolSku
    userPoolSKU: aksUserPoolSku
    thirdPartySKU: aksThirdPartyPoolSku
    sshRsaPubKey: global_pubkey.outputs.publicKey
  }
}

module global_aks_acr_pull 'assignacrpull.bicep' = {
  dependsOn: [global_acr, global_aks]
  name: 'AssignACRPullRole'
  params: {
    aksPrincipalId: global_aks.outputs.clusterPrincipalID
    registryName: global_acr.outputs.acrSymbolicName
    roleAcrPull: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
  }
}

module uni_events_kv_ppe 'keyvault.bicep' = {
  name: 'DeployUniEventsKv'
  params: {
    customer: customer
    env: env
    location: location
    name: uniEventsPpeKvName
  }
}
