$step = 0
$Zone = 'francecentral'
$RessourceGroupName = 'GiteaFirst'
$VnetName = 'GiteaVnet'
$PlageIPVnet = '10.0.1.0/24'
$PlageIPBastion = '10.0.1.64/26'
$SubNetAppName = 'GiteaSubnet'
$PlageIPApp = '10.0.1.0/28'
$NameIPBastion = 'MyFirstPublicIpBastion'
$NameBastion = 'Bastion'
$NameDB = 'GiteaSQLsvr'
$NameUserDB = 'Gitea'
$NameVM = 'VMGitea'

$error.Clear()
try {

if ($step -lt 1 ) {
az group create -l $Zone -n $RessourceGroupName
    if ($? -eq $false) {
        throw 'la création du groupe de ressource GiteaFirst a échoué'
    }
}

if ($step -lt 2) {
az network vnet create `
    -g $RessourceGroupName `
    -n $VnetName `
    --address-prefix $PlageIPVnet
    if ($? -eq $false) {
        throw 'la création du Vnet GiteaVnet a échoué'
    }
}
if ($step -lt 3) {
az network vnet subnet create `
    -g $RessourceGroupName `
    --vnet-name $VnetName `
    --name AzureBastionSubnet `
    --address-prefixes $PlageIPBastion
    if ($? -eq $false) {
        throw 'la création du Subnet SubnetBastion a échoué'
    }
}
if ($step -lt 4) {
az network vnet subnet create `
    -g $RessourceGroupName `
    --vnet-name $VnetName `
    --name $SubNetAppName `
    --address-prefixes $PlageIPApp
    if ($? -eq $false) {
        throw 'la création du Subnet GiteaSubnet a échoué'
    }
}
if ($step -lt 5) {
az network public-ip create `
    -g $RessourceGroupName `
    -n $NameIPBastion `
    --sku Standard -z 1
     if ($? -eq $false) {
        throw "la création de l'IP public Bastion a échoué"
    }
}
if ($step -lt 6) {
    az network bastion create `
    --only-show-errors `
    -l $Zone `
    -n $NameBastion `
	--public-ip-address $NameIPBastion `
	-g $RessourceGroupName `
    --vnet-name $VnetName
     if ($? -eq $false) {
        throw 'la création du service Bastion a échoué'
    }

}
if ($step -lt 7) {
az vm create -n $NameVM -g $RessourceGroupName `
	--image UbuntuLTS `
	--private-ip-address 10.0.1.4 `
	--public-ip-sku Standard
if ($? -eq $false) {
        throw 'la création de la VM a échoué'
    }
}
	
if ($step -lt 8) {
    az mysql server create -l $Zone `
    -g $RessourceGroupName `
    -n $NameDB `
    -u $NameUserDB `
    -p $Env:passwdSQL `
    --sku-name B_Gen5_1 `
    --ssl-enforcement Enabled `
    --minimal-tls-version TLS1_0 `
    --public-network-access Disabled `
	--backup-retention 14 `
    --geo-redundant-backup Disabled `
    --storage-size 51200 `
    --tags "key=value" `
    --version 5.7 `
    --only-show-errors 
    if ($? -eq $false) {
        throw 'la création du serveur MYSQL a échoué'
    }
}
}

catch {
    Write-Host "In CATCH"
    Write-Host $Error
    write-host "les ressource Azure créées vont être supprimées:"
    #az group delete -n GiteaFirst -y
}