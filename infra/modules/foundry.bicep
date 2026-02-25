@description('Base name for AI Services resources')
param name string

@description('Location for resources')
param location string = resourceGroup().location

@description('Tags to apply to all resources')
param tags object = {}

resource aiServicesAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: 'ai-${name}'
  location: location
  tags: tags
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: 'ai-${name}'
    publicNetworkAccess: 'Enabled'
  }
}

resource gpt4oDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: aiServicesAccount
  name: 'gpt-4o'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-11-20'
    }
  }
}

resource phiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: aiServicesAccount
  name: 'Phi-4'
  dependsOn: [gpt4oDeployment]
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'Microsoft'
      name: 'Phi-4'
      version: '7'
    }
  }
}

output endpoint string = aiServicesAccount.properties.endpoint
output name string = aiServicesAccount.name
