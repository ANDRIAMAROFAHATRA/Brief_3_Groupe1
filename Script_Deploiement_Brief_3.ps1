az extension add -n ssh

$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8

$Month = Get-Date -Format 'MM'
$Year = Get-Date -Format "yyyy"
$Day = Get-Date -Format "dd"
$hour = Get-Date -Format "HH:mm"
$allOutput = "$hour`nLancement du script:`n"
$Log_Path = "..\Deploiement_Gitea_$Year$Month$Day.log"
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
$NameservDB = 'giteasqlsrv'
$NameUserDB = 'Gitea'
$NameVM = 'VMGitea'
$NameDB = 'gitea'
$Dns_Name = 'giteafirst'
#ajouter une fonction pour passer $NameservDB en minuscule

try {
#-------------------CREATION DU GROUPE DU RESSOURCE ET DU RESEAU---------------------------------
if (!$Env:passwdSQL) {
    Write-Host 'Avez-vous mis le mot de passe? NON. C est chiant. Honte à vous. Try again.'
    exit
}

if ($step -lt 1 ) {
$sortie = az group create `
-l $Zone `
-n $RessourceGroupName 2>&1
$echec = $?
$hour = Get-Date -Format "HH:mm"
$allOutput += "`nEtape 1`n$hour`n$sortie`n"
    if ($echec -eq $false) {
        throw 'la création du groupe de ressource a échoué'
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
    $echec = $?
    $allOutput += "`nEtape 2`n$hour`n$sortie`n"
    if ($echec -eq $false) {
        throw 'la création du Vnet GiteaVnet a échoué'
    }
    else {
        Write-Host "Le Vnet a été créé avec succès"-ForegroundColor Cyan
    }
}

#-------------------------CREATION DES DEUX SUBNETS ---------------------------------------
if ($step -lt 3) {
$sortie = az network vnet subnet create `
    -g $RessourceGroupName `
    --vnet-name $VnetName `
    --name AzureBastionSubnet `
    --address-prefixes $PlageIPBastion 2>&1
    $echec = $?
    $hour = Get-Date -Format "HH:mm"
    $allOutput += "`nEtape 3`n$hour`n$sortie`n"
    if ($echec -eq $false) {
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
    $echec = $?
    $hour = Get-Date -Format "HH:mm"
    $allOutput += "`nEtape 4`n$hour`n$sortie`n"
    if ($echec -eq $false) {
        throw 'la création du Subnet GiteaSubnet a échoué'
    }
    else {
        Write-Host "Le subnet de Gitea a été créé avec succès" -ForegroundColor Green
    }
}

#--------------------------Creation IP PUBLIC BASTION------------------------------
if ($step -lt 5) {
$sortie = az network public-ip create `
    -g $RessourceGroupName `
    -n $NameIPBastion `
    --sku Standard -z 1 2>&1
    $echec = $?
    $hour = Get-Date -Format "HH:mm"
    $allOutput += "`nEtape 5`n$hour`n$sortie`n"
     if ($echec -eq $false) {
        throw "la création de l'IP public Bastion a échoué"
    }
    else {
        Write-Host "L'IP publique bastion a été créé avec succès" -ForegroundColor DarkCyan
    }
}

#---------------------------------CREATION BASTION ---------------------

if ($step -lt 6) {
$sortie = az network bastion create `
    --only-show-errors `
    -l $Zone `
    -n $NameBastion `
	--public-ip-address $NameIPBastion `
	-g $RessourceGroupName `
    --vnet-name $VnetName 2>&1
    $echec = $?
    $hour = Get-Date -Format "HH:mm"
    $allOutput += "`nEtape 6`n$hour`n$sortie`n"
     if ($echec -eq $false) {
        throw 'la création du service Bastion a échoué'
    }
    else {
        Write-Host "Le bastion a été créé avec succès" -ForegroundColor DarkMagenta
    }

}

#------------------FIND ID BASTION ----------------------------

$IdBastion = az network bastion list --only-show-errors -g $RessourceGroupName --query "[0].id"

#---------------------Tunnelling bastion ------------------------------
if ($step -lt 7) {
$sortie = az resource update --ids $IdBastion --set properties.enableTunneling=True 2>&1
    $echec = $?
    $hour = Get-Date -Format "HH:mm"
    $allOutput += "`nEtape 7`n$hour`n$sortie`n"
if ($echec -eq $false) {
        throw 'Activation du tunnel Bastion échoué'
    }
    else {
        Write-Host "Activation du tunnel Bastion avec succès" -ForegroundColor Green
    }
}

#----------------CREATION DE MYSQL SERVER------------------------	
if ($step -lt 8) {
$sortie = az mysql server create -l $Zone `
    -g $RessourceGroupName `
    -n $NameservDB `
    -u $NameUserDB `
    -p $Env:passwdSQL `
    --sku-name B_Gen5_1 `
    --ssl-enforcement Enabled `
    --minimal-tls-version TLS1_0 `
    --public-network-access Enabled `
	--backup-retention 14 `
    --geo-redundant-backup Disabled `
    --storage-size 51200 `
    --tags "key=value" `
    --version 5.7 `
    --only-show-errors 2>&1
    $echec = $?
    $hour = Get-Date -Format "HH:mm"
    $allOutput += "`nEtape 8`n$hour`n$sortie`n"
    if ($echec -eq $false) {
        throw 'la création du serveur MYSQL a échoué'
    }
    else {
        Write-Host "La création du serveur MySQL a été un succès" -ForegroundColor Cyan
    }
}
$ipserver = az vm show -d --resource-group $RessourceGroupName -n $NameVM --query publicIps -o tsv


if ($step -lt 9){
    $sortie = az mysql db create `
    -n $NameDB `
    -g $RessourceGroupName `
    --charset utf8mb4 `
    -s $NameservDB 2>&1
    $echec = $?
    $hour = Get-Date -Format "HH:mm"
    allOutput += "`nEtape 9`n$hour`n$sortie`n"
    if ($echec -eq $false) {
        throw 'la création de la database Gitea a échoué'
    }
    else {
        Write-Host "La database $NameDB a été créée avec succès" -ForegroundColor Blue
    }
}

#----------------------CREATION DE LA VM GITEA----------------------------
(Get-Content .\cloud-init.txt) -replace 'PASSWD   = MOTDEPASSE', "PASSWD   = $Env:passwdSQL" | Out-File .\cloud-init.txt

if ($step -lt 10) {
    $sortie = az vm create -n $NameVM -g $RessourceGroupName `
        --image UbuntuLTS `
        --private-ip-address 10.0.1.4 `
        --public-ip-sku Standard `
        --data-disk-sizes-gb 32 `
        --public-ip-address-dns-name $Dns_Name `
        --size Standard_B2s `
        --custom-data cloud-init.txt 2>&1
        $echec = $?
        $hour = Get-Date -Format "HH:mm"
        $allOutput += "`nEtape 10`n$hour`n$sortie`n"
    if ($echec -eq $false) {
            throw 'la création de la VM a échoué'
        }
        else {
            Write-Host "La VM a été créé avec succès" -ForegroundColor Yellow
        }
    }
    (Get-Content .\cloud-init.txt) -replace "PASSWD   = $Env:passwdSQL", 'PASSWD   = MOTDEPASSE' | Out-File .\cloud-init.txt
#--------------------------firewall_MySQL---------------------------------------------
    $ipserver = az vm show -d --resource-group $RessourceGroupName -n $NameVM --query publicIps -o tsv

if ($step -lt 11){
    $sortie = az mysql server firewall-rule create `
        -g $RessourceGroupName `
        --server-name $NameservDB `
        -n IpGiteaDB `
        --start-ip-address $ipserver `
        --end-ip-address $ipserver 2>&1
     $echec = $?
     $hour = Get-Date -Format "HH:mm"
     $allOutput += "`nEtape 11`n$hour`n$sortie`n"
     if ($echec -eq $false) {
        throw 'la création de la régle firewall du serveur MYSQL a échoué'
    }
    else {
        Write-Host "La régle du firewall mySQL a été créée avec succès" -ForegroundColor Magenta
    }
}

#----------------------OUVERTURE DES PORTS----------------------------

if ($step -lt 12) {
    $sortie = az vm open-port -n $NameVM -g $RessourceGroupName `
        --port 443 `
        --priority 800 2>&1
    $echec = $?
    $hour = Get-Date -Format "HH:mm"
    $allOutput += "`nEtape 12`n$hour`n$sortie`n"
    if ($echec -eq $false) {
            throw "Ouverture du port 443 a échoué"
        }
        else {
            Write-Host "Le port 443 a été créé avec succès" -ForegroundColor Yellow
        }
    }

    if ($step -lt 13) {
        $sortie = az vm open-port -n $NameVM -g $RessourceGroupName `
            --port 3000 `
            --priority 700 2>&1
        $echec = $?
        $hour = Get-Date -Format "HH:mm"
        $allOutput += "`nEtape 13`n$hour`n$sortie`n"
        if ($echec -eq $false) {
                throw "Ouverture du port 3000 a échoué"
            }
            else {
                Write-Host "Le port 3000 a été créé avec succès" -ForegroundColor Yellow
            }
        }
$allOutput >> "$Log_Path"
}

catch {
    $stderr = $allOutput | ?{ $_ -is [System.Management.Automation.ErrorRecord] }
    Write-Host "In CATCH"
    Write-Host $stderr -ForegroundColor Red
    $allOutput >> "$Log_Path"

    Write-Host "les ressources Azure créées vont être supprimées!" -ForegroundColor DarkRed
    #az group delete -n $RessourceGroupName -y
}
