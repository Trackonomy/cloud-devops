param env string
param customer string
param location string = resourceGroup().location
param appServiceName string
param aspId string
@allowed(['16-lts', '18-lts'])
param nodeVersion string = '16-lts'

var linuxFsVersion = 'node|${nodeVersion}'

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
      linuxFxVersion: linuxFsVersion
    }
  }
}
