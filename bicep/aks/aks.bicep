param location string = resourceGroup().location
param env string
param customer string = 'unicorn'
param aksName string
param availabilityZones array = []
param systemPoolScale int = 1
param userPoolScale int
param dnsPrefix string = '${customer}-${env}'
@allowed([
  'Free'
  'Standard'
])
param k8sTier string = 'Free'
@description('Node SKU as defined in https://learn.microsoft.com/en-us/azure/aks/hybrid/concepts-support')
@allowed([
  'Default'
  'Standard_A2_v2'
  'Standard_A4_v2'
  'Standard_D2s_v3'
  'Standard_D4s_v3' 
  'Standard_D8s_v3' 
  'Standard_D16s_v3' 	
  'Standard_D32s_v3'
  'Standard_DS2_v2'
  'Standard_DS3_v2' 
  'Standard_DS4_v2' 
  'Standard_DS5_v2' 	
  'Standard_DS13_v2' 
  'Standard_K8S_v1'
  'Standard_K8S2_v1'
  'Standard_K8S3_v1'
  'Standard_NK6'
  'Standard_NK12'
])
param vmSKU string = 'Standard_A4_v2'
@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

resource aks 'Microsoft.ContainerService/managedClusters@2023-06-01' = {
  location: location
  name: aksName
  tags: {
    env: env
    customer: customer
  }
  sku: {
    name: 'Base'
    tier: k8sTier
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        availabilityZones: availabilityZones
        count: systemPoolScale
        enableAutoScaling: false
        kubeletDiskType: 'OS'
        mode: 'System'
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
        osDiskSizeGB: 0
        osSKU: 'Ubuntu'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        vmSize: vmSKU
      }
      {
        name: 'apppool'
        availabilityZones: availabilityZones
        count: userPoolScale
        enableAutoScaling: false
        kubeletDiskType: 'OS'
        mode: 'User'
        osDiskSizeGB: osDiskSizeGB
        osSKU: 'Ubuntu'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        vmSize: vmSKU
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: sshRSAPublicKey == '' ? {} : {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
  }
}

output clusterPrincipalID string = aks.properties.identityProfile.kubeletidentity.objectId
output clusterRG string = aks.properties.nodeResourceGroup
