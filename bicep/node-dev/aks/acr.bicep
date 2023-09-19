param location string = resourceGroup().location
param registryName string
param env string
param customer string = 'unicorn'
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'
param aksPrincipalId string
@allowed([
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
  'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
])
param roleAcrPull string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

var roleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '${roleAcrPull}')
resource acr 'Microsoft.ContainerRegistry/registries@2023-06-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
  tags: {
    env: env
    customer: customer
  }
}
resource AssignAcrPullToAks 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, registryName,  aksPrincipalId, 'AssignAcrPullToAks')
  scope: acr
  properties: {
    description: 'Assign ACR Pull role to aks'
    principalId: aksPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinitionId
  }
}
