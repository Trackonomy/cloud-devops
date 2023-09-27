/*
This 
*/
@description('Id of kubernetes cluster principal')
param aksPrincipalId string

@description('Name of the ACR')
param registryName string

@allowed([
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
  'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
  '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull
])
@description('Id of acr role applied to k8s identity.')
param roleAcrPull string = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

var roleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '${roleAcrPull}')

resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' existing = {
  name: registryName
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
