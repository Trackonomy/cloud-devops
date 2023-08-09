param location string = resourceGroup().location
param sbNamespaceName string
@description('Name of service bus queue. During creation will be appended number 1 or 2 at the end.')
param sbQueuesName string
param customer string = 'unicorn'
param env string
@allowed(['Basic', 'Premium', 'Standard'])
param sbSku string
@allowed([1, 2, 4, 8, 16])
param sbCapacity int
param zoneRedundant bool
@allowed([1, 2])
param numOfQueues int

resource sbNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = { 
  location: location
  name: sbNamespaceName
  tags: {
    env: env
    customer: customer
  }
  sku: { 
    name: sbSku
    capacity: sbCapacity
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    premiumMessagingPartitions: 1
    disableLocalAuth: false
    zoneRedundant: zoneRedundant
  }
}

resource sbQueues 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = [for i in range (0, numOfQueues): {
  name: '${sbQueuesName}-${i}'
  parent: sbNamespace
  properties: {
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    defaultMessageTimeToLive: 'P14D'
    duplicateDetectionHistoryTimeWindow: 'string'
    enableBatchedOperations: true
    enableExpress: false
    enablePartitioning: false
    forwardDeadLetteredMessagesTo: 'string'
    lockDuration: 'PT30S'
    maxDeliveryCount: 10
    maxMessageSizeInKilobytes: 1024
    maxSizeInMegabytes: 5120
    requiresDuplicateDetection: false
    requiresSession: true
    status: 'Active'
  }
}]
