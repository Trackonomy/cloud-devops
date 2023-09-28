@description('Id of kubernetes cluster principal')
param aksPrincipalId string

param readerRole string = 'b24988ac-6180-42a0-ab88-20f7382dd24c' //contributor
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
