using './main.bicep'

param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', 'dev')
param location = readEnvironmentVariable('AZURE_LOCATION', 'westus3')
param aiServicesLocation = readEnvironmentVariable('AZURE_AI_SERVICES_LOCATION', 'westus3')
