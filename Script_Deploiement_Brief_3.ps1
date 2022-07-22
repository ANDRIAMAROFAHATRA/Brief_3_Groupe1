
while ($(az group exists -n GiteaFirst) -eq $false) {
    az group create -l francecentral -n GiteaFirst
    Write-Host "Ressource Groupe Create"
}
Write-Host "Etape2"
