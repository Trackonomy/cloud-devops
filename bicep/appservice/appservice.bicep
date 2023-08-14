param env string
param customer string
param location string = resourceGroup().location
param appServiceName string
param aspId string

resource appService 'Microsoft.Web/sites@2022-09-01' = { 
  location: location
  name: appServiceName
  tags: {
    env: env
    customer: customer
  }
  properties: { 
    serverFarmId: aspId
    siteConfig: {
      linuxFxVersion: 'NODE|16-lts'
    }
  }
}
