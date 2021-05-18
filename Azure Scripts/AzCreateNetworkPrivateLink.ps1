[CmdletBinding()]
param (
    [string] $newVnetSubscriptionName = "",
    [string] $vnetrg = "",
    [string] $vnetName = "",
    [string] $subnetName = '',
    [string] $dnsZoneSubscriptionName = "",  
    [string] $dnsZoneRgName = '',
    [Parameter(Mandatory)]
    [string] $privateZoneName = ''

)
Connect-AzAccount

Select-AzSubscription -Subscription $newVnetSubscriptionName
[bool]$notExist = $true 
try {
    $vnet = Get-AzVirtualNetwork -ResourceGroupName $vnetrg -Name $vnetName -ErrorAction Stop
    ## Get Subnet into variable
    $subnet = $vnet | Select-Object -ExpandProperty subnets | Where-Object Name -eq $subnetName
    ## Disable private endpoint network policy ##
    $subnet.PrivateEndpointNetworkPolicies = "Disabled"
    $vnet | Set-AzVirtualNetwork       
}
catch {
    Write-Host $vnetName "does not exist" -ForegroundColor Yellow
    $_.Exception
}

Select-AzSubscription -Subscription $dnsZoneSubscriptionName

$parameters1 = @{
    ResourceGroupName = $dnsZoneRgName
    Name = $privateZoneName
}
try {
    $zone = Get-AzPrivateDnsZone @parameters1    
    $zone    
}
catch {
    Write-Host "failed to get the DNS ZOne:" $privateZoneName
}

$parameters2 = @{
    ResourceGroupName = $dnsZoneRgName
    ZoneName = $zone.Name
    Name = -join($zone.Name,"-to-",$vnet.Name)
    VirtualNetworkId = $vnet.Id
}
$privateDnsVirtualNetworkLinkName = -join($zone.Name,"-to-",$vnet.Name)
try{
    $checkExistingLink = Get-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $dnsZoneRgName -ZoneName $privateZoneName -Name $privateDnsVirtualNetworkLinkName -ErrorAction Stop
    $notExist = $false
    Write-Host "listing resource starting : --------------------" -ForegroundColor Yellow
    $checkExistingLink
    
    Write-Host "listing resource ending : --------------------" -ForegroundColor Yellow
}
catch{
    $notExist = $true
    Write-Host "link does not exist" -ForegroundColor Red
}
if ($notExist)
{ 
    Write-Host "creating virtual link: -------------------------" -ForegroundColor Green
    $link = New-AzPrivateDnsVirtualNetworkLink @parameters2
    $link
    Write-Host "completed creating virtual link: -------------------------" -ForegroundColor Green

}