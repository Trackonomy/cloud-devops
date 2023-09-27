param location string = resourceGroup().location
param pubIpName string
param env string
param customer string
@allowed(['Basic', 'Standard'])
param sku string
param static bool

@description('Array of strings representing zones')
param zones array = []

resource pubip 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: pubIpName
  location: location
  tags: {
    env: env
    customer: customer
  }
  sku: {
    name: sku
    tier: 'Regional'
  }
  zones: zones
  properties:{
    publicIPAllocationMethod: static ? 'Static' : 'Dynamic'
  }
}
