#----------INITIALISATION DES VARIABLES SELON POSTE LOCAL -------------------------


$Rsa_Path_Local = '<chemin cle priv>'
$RessourceGroupName = 'GiteaFirst'
$NameBastion = 'Bastion'
$UserSQL = 'steph'

#-------------PARSE JSON DE L' ID DE LA VM + CONNEXION ----------------------------


$Id_VM1 = az vm list -g $RessourceGroupName --query [0].id

az network bastion ssh --auth-type ssh-key --ssh-key $Rsa_Path_Local --username $UserSQL -g $RessourceGroupName --target-resource-id $Id_VM1 -n $NameBastion

