#----------INITIALISATION DES VARIABLES SELON POSTE LOCAL -------------------------


$Rsa_Path_Local = 'C:\Users\utilisateur\.ssh\id_rsa'
$RessourceGroupName = 'GiteaFirst'
$NameBastion = 'Bastion'

#-------------PARSE JSON ID DE LA VM + CONNEXION ----------------------------
$Id_VM1 = az vm list -g $RessourceGroupName --query"[0].id"
az network bastion ssh --auth-type ssh-key --ssh-key $Rsa_Path_Local --username utilisateur -g $RessourceGroupName --target-resource-id $Id_VM1 -n $NameBastion