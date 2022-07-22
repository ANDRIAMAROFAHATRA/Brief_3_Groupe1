try {
    Start-Process az -ErrorVariable errcmd
    az group create -l francecentral -n GiteaFirst 

az network vnet create `
    -g GiteaFirst `
    -n GiteaVnet `
    --address-prefix 10.0.1.0/24 `

az network vnet subnet create `
    -g GiteaFirst `
    --vnet-name GiteaVnet `
    --name SubnetBastion `
    --address-prefixes 10.0.164/26 `

az network vnet subnet create `
    -g GiteaFirst `
    --vnet-name GiteaVnet `
    --name GiteaSubnet `
    --address-prefixes 10.az0.1.0/29 `

az network vnet subnet list -g GiteaFirst --vnet-name GiteaVnet

}

catch {
    write-host $Error
    az group delete -n GiteaFirst -y
}
