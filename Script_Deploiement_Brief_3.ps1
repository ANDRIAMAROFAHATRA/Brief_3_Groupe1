$error.Clear()
try {

az group create -l francecentral -n GiteaFirst
    if ($? -eq $false) {
        throw 'la création du groupe de ressource GiteaFirst a échoué'
    }

az network vnet create `
    -g GiteaFirst `
    -n GiteaVnet `
    --address-prefix 10.0.1.0/24
    if ($? -eq $false) {
        throw 'la création du Vnet GiteaVnet a échoué'
    }

az network vnet subnet create `
    -g GiteaFirst `
    --vnet-name GiteaVnet `
    --name SubnetBastion `
    --address-prefixes 10.0.1.64/26
    if ($? -eq $false) {
        throw 'la création du Subnet SubnetBastion a échoué'
    }

az network vnet subnet create `
    -g GiteaFirst `
    --vnet-name GiteaVnet `
    --name GiteaSubnet `
    --address-prefixes 10.0.10/29 
    if ($? -eq $false) {
        throw 'la création du Subnet GiteaSubnet a échoué'
    }

}

catch {
    write-host $error
    write-host "les ressource Azure crées vont être supprimées:"
    az group delete -n GiteaFirst -y
}
