
@description('Name of the key vault')
param name string
@description('Location of the key vault')
param location string
@description('Customer. Default is multi-tenant')
param customer string
@description('Environment of key vault')
param env string

@description('Sku name. Default is Standard')
@allowed(['standard', 'premium'])
param skuName string = 'standard'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  tags: {
    customer: customer
    env: env
  }
  properties: {
    enableRbacAuthorization: true
    sku: {
      family: 'A'
      name: skuName
    }
    tenantId: 'a92ebf37-cae1-460d-8a16-ce7d28d0ff9c' //trackonomy tenant
  }
}

output kvName string = keyVault.name
