param location string = resourceGroup().location
param sbNamespaceName string
param customer string = 'unicorn'
param env string
@allowed(['Basic', 'Premium', 'Standard'])
param sbSku string
@allowed([1, 2, 4, 8, 16])
param sbCapacity int
resource sbNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = { 
  location: location
  name: sbNamespaceName
  tags: {
    env: env
    customer: customer
  }
  properties: {
    premiumMessagingPartitions: 1
  }
  sku: { 
    name: sbSku
    tier:
    capacity: sbCapacity
  }
}
