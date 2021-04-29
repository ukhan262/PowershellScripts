$ErrorActionPreference = "SilentlyContinue";

Connect-AzAccount;

$sub = "";

Select-AzSubscription -subscription $sub

$resourceGroupName = "";
$rtName = "";
$fileName = ".csv";

$RouteTable = Get-AzRouteTable -ResourceGroupName $resourceGroupName -Name $rtName

$fileLocation = ".\$fileName"
Import-Csv $fileLocation | `
ForEach-Object {
    try {
        Write-Host "Name: " $_.Name;
        Write-Host "Address Prefix: " $_.AddressPrefix;
        Write-Host "Adding and setting route config";
    
        Add-AzRouteConfig -RouteTable $RouteTable `
                          -Name $_.Name `
                          -AddressPrefix $_.AddressPrefix `
                          -NextHopType "Internet" | Set-AzRouteTable
    
        Write-host "Record added";
        Write-Host "------------------------------"  
    }
    catch {
        Write-Host "record not added."
    }                      
}