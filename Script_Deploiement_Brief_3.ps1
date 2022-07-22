
while ($(az group exists -n GiteaFirst) -eq $false) {
    az group create -l francecentral -n GiteaFirst
    Write-Host "Ressource Groupe Create"
}
Write-Host "Etape2"

az network vnet create `
    -g GiteaFirst `
    -n GiteaVnet `
    --address-prefix 10.0.1.0/24 `
   
az network vnet subnet create `
    -g GiteaFirst `
    --vnet-name GiteaVnet `
    --name SubnetBastion `
    --address-prefixes 10.0.1.64/26 `

az network vnet subnet create `
    -g GiteaFirst `
    --vnet-name GiteaVnet `
    --name GiteaSubnet `
    --address-prefixes 10.0.1.0/29 `

az network vnet subnet list -g GiteaFirst --vnet-name GiteaVnet
