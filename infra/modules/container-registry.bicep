@description('Base name for ACR (alphanumeric only, 5-50 chars)')
param name string

@description('Location for resources')
param location string = resourceGroup().location

@description('Tags to apply to all resources')
param tags object = {}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: replace('cr${name}', '-', '')
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

output name string = containerRegistry.name
output loginServer string = containerRegistry.properties.loginServer
output id string = containerRegistry.id
