<#
    
#>

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
        Write-Output "Name: " $_.Name;
        Write-Output "Address Prefix: " $_.AddressPrefix;
        Write-Output "Adding and setting route config";
    
        Add-AzRouteConfig -RouteTable $RouteTable `
                          -Name $_.Name `
                          -AddressPrefix $_.AddressPrefix `
                          -NextHopType "Internet" | Set-AzRouteTable
    
        Write-Output "Record added";
        Write-Output "------------------------------"  
    }
    catch {
        Write-Output "record not added."
    }                      
}