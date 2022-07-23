try {

az group create -l francecentral -n GiteaFirst
    if ($? -eq $false) {
        $erreur = "la création du groupe de ressource GiteaFirst a échoué"
        throw ''
    }

az network vnet create `
    -g GiteaFirst `
    -n GiteaVnet `
    --address-prefix 10.0.1.0/24
    if ($? -eq $false) {
        $erreur = "la création du Vnet GiteaVnet a échoué"
        throw ''
    }

az network vnet subnet create `
    -g GiteaFirst `
    --vnet-name GiteaVnet `
    --name SubnetBastion `
    --address-prefixes 10.0.1.64/26
    if ($? -eq $false) {
        $erreur = "la création du Subnet SubnetBastion a échoué"
        throw ''
    }

az network vnet subnet create `
    -g GiteaFirst `
    --vnet-name GiteaVnet `
    --name GiteaSubnet `
    --address-prefixes 10.az0.1.0/29
    if ($? -eq $false) {
        $erreur = "la création du Subnet GiteaSubnet a échoué"
        throw ''
    }

}

catch {
    Write-Host $ErrorView
    write-host $Erreur
    az group delete -n GiteaFirst -y
}
