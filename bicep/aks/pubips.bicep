param env string
param customer string = 'unicorn'
param location string = resourceGroup().location
param ipNamePostfix string = '${env}-${customer}-${location}'
var servicesNames  = [
  'mobile'
  'filter'
  'external'
  'health-dash'
  'util'
  'tapeevents'
]
resource servicesPubips 'Microsoft.Network/publicIPAddresses@2023-04-01' = [ for i in range (0, 6) : {
  name: '${servicesNames[i]}-${ipNamePostfix}'
  location: location
  tags: {
    customer: customer
    env: env
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}]
