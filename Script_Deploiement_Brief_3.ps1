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


try {

if ($step -lt 1 ) {
$allOutput = az group create .\.git `
-l $Zone `
-n $RessourceGroupName 2>>&1
    if ($? -eq $false) {
        throw 'la création du groupe de ressource GiteaFirst a échoué'
    }
}

if ($step -lt 2) {
$allOutput = az network vnet create `
    -g $RessourceGroupName `
    -n $VnetName `
    --address-prefix $PlageIPVnet 2>>&1
    if ($? -eq $false) {
        throw 'la création du Vnet GiteaVnet a échoué'
    }
}
if ($step -lt 3) {
$allOutput = az network vnet subnet create `
    -g $RessourceGroupName `
    --vnet-name $VnetName `
    --name AzureBastionSubnet `
    --address-prefixes $PlageIPBastion 2>>&1
    if ($? -eq $false) {
        throw 'la création du Subnet SubnetBastion a échoué'
    }
}
if ($step -lt 4) {
$allOutput = az network vnet subnet create `
    -g $RessourceGroupName `
    --vnet-name $VnetName `
    --name $SubNetAppName `
    --address-prefixes $PlageIPApp 2>>&1
    if ($? -eq $false) {
        throw 'la création du Subnet GiteaSubnet a échoué'
    }
}
if ($step -lt 5) {
$allOutput = az network public-ip create `
    -g $RessourceGroupName `
    -n $NameIPBastion `
    --sku Standard -z 1 2>>&1
     if ($? -eq $false) {
        throw "la création de l'IP public Bastion a échoué"
    }
}
if ($step -lt 6) {
$allOutput = az network bastion create `
    --only-show-errors `
    -l $Zone `
    -n $NameBastion `
	--public-ip-address $NameIPBastion `
	-g $RessourceGroupName `
    --vnet-name $VnetName 2>>&1
     if ($? -eq $false) {
        throw 'la création du service Bastion a échoué'
    }

}
if ($step -lt 7) {
$allOutput = az vm create -n $NameVM -g $RessourceGroupName `
	--image UbuntuLTS `
	--private-ip-address 10.0.1.4 `
	--public-ip-sku Standard 2>>&1
if ($? -eq $false) {
        throw 'la création de la VM a échoué'
    }
}
	
if ($step -lt 8) {
$allOutput = az mysql server create -l $Zone `
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
    --only-show-errors 2>>&1
    if ($? -eq $false) {
        throw 'la création du serveur MYSQL a échoué'
    }
}
}

catch {
    $stderr = $allOutput | ?{ $_ -is [System.Management.Automation.ErrorRecord] }
    $stdout = $allOutput | ?{ $_ -isnot [System.Management.Automation.ErrorRecord] }
    Write-Host "In CATCH"
    Write-Host $stderr
    $stdout > ../test.log
    write-host "les ressource Azure créées vont être supprimées:"
    #az group delete -n GiteaFirst -y
}