param location string = resourceGroup().location
param aksName string
param availabilityZones array = []
param customer string
param env string = 'shared'
@description('Number of vms for system pool')
param systemPoolScale int
@description('Number of vms for user pool')
param userPoolScale int
@description('Number of instances for 3rd party pool')
param thirdPartyPoolScale int

param dnsPrefix string = '${customer}-${env}'

@allowed(['Free', 'Standard'])
param k8sTier string = 'Free'

@description('SKU of system node pools. Available values: please see userPoolSKU')
param systemPoolSKU string

@description('Max count of system pool')
param systemMaxCount int

@description('Public ssh key to connect to VMs.')
param sshRsaPubKey string

@description('Node SKU as defined in https://learn.microsoft.com/en-us/azure/aks/hybrid/concepts-support')
param userPoolSKU string

@description('SKU of third-party node pools. Available values: please see userPoolSKU')
param thirdPartySKU string

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string = 'Admin01'



resource aks 'Microsoft.ContainerService/managedClusters@2023-07-02-preview' = {
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
    enableNamespaceResources: false
    storageProfile: {
      blobCSIDriver: {
        enabled: true
      }
      diskCSIDriver: {
        enabled: true
        version: 'v1'
      }
      fileCSIDriver: {
        enabled: true
      }
      snapshotController: {
        enabled: true
      }
    }
    addonProfiles: {
      azureKeyVaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'agentpool'
        availabilityZones: availabilityZones
        minCount: systemPoolScale
        enableAutoScaling: true
        kubeletDiskType: 'OS'
        mode: 'System'
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
        osDiskSizeGB: 0
        osSKU: 'Ubuntu'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        count: systemPoolScale
        maxCount: systemMaxCount
        vmSize: systemPoolSKU
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
        vmSize: userPoolSKU
        nodeLabels: {
          workload: 'apps'
        }
      }
      {
        name: 'utilpool'
        availabilityZones: availabilityZones
        count: thirdPartyPoolScale
        enableAutoScaling: false
        kubeletDiskType: 'OS'
        mode: 'User'
        osDiskSizeGB: osDiskSizeGB
        osSKU: 'Ubuntu'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        vmSize: thirdPartySKU
        nodeLabels: {
          workload: 'thirdparty'
        }
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRsaPubKey
          }
        ]
      }
    }
  }
}

output clusterPrincipalID string = aks.properties.identityProfile.kubeletidentity.objectId
output pubKey string = aks.properties.linuxProfile.ssh.publicKeys[0].keyData
output clusterRG string = aks.properties.nodeResourceGroup
output clusterSpClientI string = aks.identity.principalId
