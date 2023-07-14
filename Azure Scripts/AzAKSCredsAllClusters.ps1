az login

az config set core.only_show_errors=yes

$subscriptions=$( az account list --all --query "[].{Name:name} | [? contains(Name, 'az3-')]" --output tsv)

foreach ($name in $subscriptions){
    Write-host "subscription name: $name" -ForegroundColor Yellow
    az account set --subscription $name
    az account show
    $k8s = (az resource list --resource-type 'Microsoft.ContainerService/managedClusters' --query "[].{Name:name,ResourceGroup:resourceGroup}" --output json) | ConvertFrom-Json
    if ( ($k8s | measure-object | select-object -expandproperty Count) -gt 0) {
        foreach($k8 in $k8s) {
            write-host "adding creds for: $k8.Name" -ForegroundColor Yellow
            az aks get-credentials --resource-group $k8.ResourceGroup --name $k8.Name --overwrite-existing 
            write-host "adding creds for: $k8.Name" -ForegroundColor Green  
        }
    }
    else {
        write-host "no clusters in $name subscription" -ForegroundColor Red
        write-host "================================="
    }
}