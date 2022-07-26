$Month = Get-Date -Format 'MMMMMM'
$Year = Get-Date -Format "yyyy"
$Day = Get-Date -Format "dd"
$allOutput = "$day $Month $Year`n`n"
$Log_Path = "../Deploiement_Gitea_$Year$Month$Day.log"
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
$sortie = az group create `
-l $Zone `
-n $RessourceGroupName 2>&1
$allOutput = "`n$sortie`n"
    if ($? -eq $false) {
        throw 'la création du groupe de ressource GiteaFirst a échoué'
    }
    else {
        Write-Host "Le groupe de ressource a été créé avec succès" -ForegroundColor Magenta
    }
}

if ($step -lt 2) {
 $sortie = az network vnet create `
    -g $RessourceGroupName `
    -n $VnetName `
    --address-prefix $PlageIPVnet 2>&1
    $allOutput += "`n$sortie`n"
    if ($? -eq $false) {
        throw 'la création du Vnet GiteaVnet a échoué'
    }
    else {
        Write-Host "Le Vnet a été créé avec succès"-ForegroundColor Cyan
    }
}
if ($step -lt 3) {
$sortie = az network vnet subnet create `
    -g $RessourceGroupName `
    --vnet-name $VnetName `
    --name AzureBastionSubnet `
    --address-prefixes $PlageIPBastion 2>&1
    $allOutput += "`n$sortie`n"
    if ($? -eq $false) {
        throw 'la création du Subnet SubnetBastion a échoué'
    }
    else {
        Write-Host "Le subnet Bastion a été créé avec succès" -ForegroundColor Yellow
    }
}
if ($step -lt 4) {
$sortie = az network vnet subnet create `
    -g $RessourceGroupName `
    --vnet-name $VnetName `
    --name $SubNetAppName `
    --address-prefixes $PlageIPApp 2>&1
    $allOutput += "`n$sortie`n"
    if ($? -eq $false) {
        throw 'la création du Subnet GiteaSubnet a échoué'
    }
    else {
        Write-Host "Le subnet de Gitea a été créé avec succès" -ForegroundColor Green
    }
}
if ($step -lt 5) {
$sortie = az network public-ip create `
    -g $RessourceGroupName `
    -n $NameIPBastion `
    --sku Standard -z 1 2>&1
    $allOutput += "`n$sortie`n"
     if ($? -eq $false) {
        throw "la création de l'IP public Bastion a échoué"
    }
    else {
        Write-Host "L'IP publique bastion a été créé avec succès" -ForegroundColor DarkCyan
    }
}
if ($step -lt 6) {
$sortie = az network bastion create `
    --only-show-errors `
    -l $Zone `
    -n $NameBastion `
	--public-ip-address $NameIPBastion `
	-g $RessourceGroupName `
    --vnet-name $VnetName 2>&1
    $allOutput += "`n$sortie`n"
     if ($? -eq $false) {
        throw 'la création du service Bastion a échoué'
    }
    else {
        Write-Host "Le bastion a été créé avec succès" -ForegroundColor DarkMagenta
    }

}
if ($step -lt 7) {
$sortie = az vm create -n $NameVM -g $RessourceGroupName `
	--image UbuntuLTS `
	--private-ip-address 10.0.1.4 `
	--public-ip-sku Standard 2>&1
    $allOutput += "`n$sortie`n"
if ($? -eq $false) {
        throw 'la création de la VM a échoué'
    }
    else {
        Write-Host "La VM a été créé avec succès" -ForegroundColor Yellow
    }
}
	
if ($step -lt 8) {
$sortie = az mysql server create -l $Zone `
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
    --only-show-errors 2>&1
    $allOutput += "`n$sortie`n"
    if ($? -eq $false) {
        throw 'la création du serveur MYSQL a échoué'
    }
    else {
        Write-Host "Le database a été créé avec succès" -ForegroundColor Green
    }
}
}

catch {
    $stderr = $allOutput | ?{ $_ -is [System.Management.Automation.ErrorRecord] }
    Write-Host "In CATCH"
    Write-Host $stderr -ForegroundColor Red
    $allOutput > $Log_Path
    write-host "les ressource Azure créées vont être supprimées:" -ForegroundColor DarkRed
    #az group delete -n GiteaFirst -y
}