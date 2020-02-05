# Docker Gource Mesa

Using named pipes with no need for GPU.  
Ready to be deployed as an Azure Container Instance.  
Copies completed video to Azure File Share.  
You can use Azure CLI CloudShell or setup WSL2 and Docker.

## Docker Locally

```bash
docker build --rm -f "Dockerfile" -t gource-mesa:latest "."

mkdir video

echo "
1524578685|First Last|A|/https://domain.repo.com/org/myrepo
1524578685|Ben Smith|A|/https://domain.repo.com/org/myrepo
1524578685|Ella Smith|A|/https://domain.repo.com/org/myrepo" > commits.log

docker run --rm --debug \
-v $(pwd)/video:/mnt/video \
-v $(pwd)/commits.log:/mnt/commits.log \
gource-mesa:latest
```

```bash
az login
```

## Provision

```bash
az account set -s "Visual Studio Enterprise"
az group create -l northeurope -n gourcerg
az storage account create -n gourcestracc -g gourcerg -l northeurope --sku Standard_LRS
az storage share create -n gourceshare --account-name gourcestracc
az acr create -n gourceacr -g gourcerg --admin-enabled true --sku Basic
```

Assumed Azure File Share directory:

```bash
├── gource-mesa
│   ├── video
│   ├── commits.log
```

## Build

```bash
az acr login -n gourceacr
az acr build -f "Dockerfile" -t gource-mesa:latest -r gourceacr "."
```

## Deploy

```bash
az container create -g gourcerg -n gource-mesa --image gourceacr.azurecr.io/gource-mesa \
--cpu 4 --memory 10 --restart-policy Never \
--azure-file-volume-share-name gourceshare --azure-file-volume-account-name gourcestracc \
--azure-file-volume-account-key $(az storage account keys list --resource-group gourcerg --account-name gourcestracc --query "[0].value" --output tsv) \
--azure-file-volume-mount-path /mnt \
--registry-username gourceacr --registry-password "00000000000000000000000000000000"
```

```bash
az container attach --name gource-mesa --resource-group gourcerg
```
