$step = 0

$error.Clear()
try {

if ($step -lt 1 ) {
az group create -l francecentral -n GiteaFirst
    if ($? -eq $false) {
        throw 'la création du groupe de ressource GiteaFirst a échoué'
    }
}

if ($step -lt 2) {
az network vnet create `
    -g GiteaFirst `
    -n GiteaVnet `
    --address-prefix 10.0.1.0/24
    if ($? -eq $false) {
        throw 'la création du Vnet GiteaVnet a échoué'
    }
}
if ($step -lt 3) {
az network vnet subnet create `
    -g GiteaFirst `
    --vnet-name GiteaVnet `
    --name AzureBastionSubnet `
    --address-prefixes 10.0.1.64/26
    if ($? -eq $false) {
        throw 'la création du Subnet SubnetBastion a échoué'
    }
}
if ($step -lt 4) {
az network vnet subnet create `
    -g GiteaFirst `
    --vnet-name GiteaVnet `
    --name GiteaSubnet `
    --address-prefixes 10.0.1.0/29
    if ($? -eq $false) {
        throw 'la création du Subnet GiteaSubnet a échoué'
    }
}
if ($step -lt 5) {
az network public-ip create `
    -g GiteaFirst -n MyFirstPublicIpBastion --sku Standard -z 1
     if ($? -eq $false) {
        throw 'la création de l'IP public Bastion a échoué'
    }
}
if ($step -lt 6) {
    az network bastion create --only-show-errors -l francecentral `
     -n Bastion `
	--public-ip-address MyFirstPublicIpBastion `
	-g GiteaFirst `
    --vnet-name GiteaVnet
     if ($? -eq $false) {
        throw 'la création du service Bastion a échoué'
    }
}
if ($step -lt 7) {
    az mysql server create -l francecentral `
    -g GiteaFirst `
    -n GiteaSQLsvr `
    -u Gitea `
     -p $Env:passwdSQL `
     --sku-name B_Gen5_1 `
     --ssl-enforcement Enabled `
     --minimal-tls-version TLS1_0 `
     --public-network-access Disabled `
	--backup-retention 14 `
    --geo-redundant-backup Enabled `
    --storage-size 51200 `
    --tags "key=value" `
    --version 5.7
    if ($? -eq $false) {
        throw 'la création du serveur MYSQL a échoué'
    }
}
}

catch {
    Write-Host "In CATCH"
    Write-Host $Error
    write-host "les ressource Azure crées vont être supprimées:"
    #az group delete -n GiteaFirst -y
}
