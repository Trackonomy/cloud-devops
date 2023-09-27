@description('Location of ACR')
param location string = resourceGroup().location
@description('Name of the ACR')
param registryName string
@description('Environment tag')
param env string
param customer string
resource acr 'Microsoft.ContainerRegistry/registries@2023-06-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: true
  }
  tags: {
    env: env
    customer: customer
  }
}

output acrSymbolicName string = acr.name
