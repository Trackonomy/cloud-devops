@description('Id of kubernetes cluster principal')
param aksPrincipalId string

param readerRole string = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var roleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '${readerRole}')
resource AssignResourceGroupList 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aksPrincipalId, 'AssignRgListToAks')
  scope: resourceGroup()
  properties: {
    description: 'Assign ACR Pull role to aks'
    principalId: aksPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinitionId
  }
}
