targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment (e.g., dev, staging, prod)')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Optional override for the AI Services location if models are unavailable in primary region')
param aiServicesLocation string = location

var tags = { 'azd-env-name': environmentName }
var resourceSuffix = take(uniqueString(subscription().id, environmentName, location), 6)

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module monitoring './modules/monitoring.bicep' = {
  scope: rg
  params: {
    name: 'zava-${resourceSuffix}'
    location: location
    tags: tags
  }
}

module containerRegistry './modules/container-registry.bicep' = {
  scope: rg
  params: {
    name: 'zava${resourceSuffix}'
    location: location
    tags: tags
  }
}

module appService './modules/app-service.bicep' = {
  scope: rg
  params: {
    name: 'zava-${resourceSuffix}'
    location: location
    tags: tags
    containerRegistryName: containerRegistry.outputs.name
    applicationInsightsConnectionString: monitoring.outputs.applicationInsightsConnectionString
  }
}

module containerRegistryAccess './modules/container-registry-access.bicep' = {
  scope: rg
  params: {
    containerRegistryName: containerRegistry.outputs.name
    principalId: appService.outputs.identityPrincipalId
  }
}

module foundry './modules/foundry.bicep' = {
  scope: rg
  params: {
    name: 'zava-${resourceSuffix}'
    location: aiServicesLocation
    tags: tags
  }
}

// Outputs — UPPERCASE names become azd env vars
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = monitoring.outputs.logAnalyticsWorkspaceId
output WEB_URL string = appService.outputs.url
output AZURE_AI_SERVICES_ENDPOINT string = foundry.outputs.endpoint
