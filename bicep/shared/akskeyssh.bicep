param location string = resourceGroup().location
param sshAksPubKeyName string
param env string
param customer string
param pubKey string

resource aksPublicKey 'Microsoft.Compute/sshPublicKeys@2023-03-01' = {
  name: sshAksPubKeyName
  location: location
  tags: {
    env: env
    customer: customer
  }
  properties:{
    publicKey: pubKey
  }
}

output publicKey string = aksPublicKey.properties.publicKey
