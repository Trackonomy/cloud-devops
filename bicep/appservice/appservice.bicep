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
  kind: 'app,linux'
  properties: { 
    serverFarmId: aspId
    reserved: true
    siteConfig: {
      minTlsVersion: '1.2'
      linuxFxVersion: 'node|18-lts'
    }
  }
}
