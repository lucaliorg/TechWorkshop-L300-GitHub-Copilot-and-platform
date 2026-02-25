# CI/CD Setup

## Prerequisites

Run `azd env get-values` to get the resource names from your deployed environment.

## GitHub Secret

| Secret | How to create |
|--------|---------------|
| `AZURE_CREDENTIALS` | `az ad sp create-for-rbac --name "github-deploy" --role Contributor --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP> --json-auth` — paste the full JSON output as the secret value |

## GitHub Variables

| Variable | Value (from `azd env get-values`) |
|----------|-----------------------------------|
| `ACR_NAME` | `AZURE_CONTAINER_REGISTRY_NAME` output |
| `APP_NAME` | Web App name (e.g., `app-zava-bduell`) |
| `RESOURCE_GROUP` | `AZURE_RESOURCE_GROUP` output (e.g., `rg-dev`) |

### Where to set them

**Settings → Secrets and variables → Actions**

- **Secrets** tab → New repository secret → `AZURE_CREDENTIALS`
- **Variables** tab → New repository variable → `ACR_NAME`, `APP_NAME`, `RESOURCE_GROUP`

## Grant the service principal AcrPush

```bash
az role assignment create \
  --role AcrPush \
  --assignee <SERVICE_PRINCIPAL_APP_ID> \
  --scope $(az acr show --name <ACR_NAME> --query id -o tsv)
```
