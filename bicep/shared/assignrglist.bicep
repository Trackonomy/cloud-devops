@description('Id of kubernetes cluster principal')
param aksPrincipalId string

param contributorRole string = 'b24988ac-6180-42a0-ab88-20f7382dd24c' //contributor
var roleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '${contributorRole}')
resource AssignResourceGroupList 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aksPrincipalId, 'AssignRgListToAks')
  scope: resourceGroup()
  properties: {
    description: 'Assign Contributor role to aks'
    principalId: aksPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinitionId
  }
}

param networkContributorRoleDefinitionId string = '4d97b98b-1d4f-4787-a291-c67834d212e7'
var networkContrubutorRoleDefinition = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '${networkContributorRoleDefinitionId}')
resource AssignNetworkContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aksPrincipalId, 'AssignNetworkContributorToAKs')
  scope: resourceGroup()
  properties: {
    description: 'Assign Network Contributor role to aks'
    principalId: aksPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: networkContrubutorRoleDefinition
  }
}
