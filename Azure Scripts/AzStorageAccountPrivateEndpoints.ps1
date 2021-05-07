<#
    This script will create the private endpoints for storage accounts for all 4 types of groupid.
    
    parameters for storage account resource
        [string]$storageAccountSubscriptionName = "",
        [string]$rgName = "",
        [string]$storageAccountName = "",
        [string]$vnetrg = "",
        [string]$vnetName = "",
        [string]$subnetName = '',

    parameters for DNS Zone resources
        [string]$dnsZoneSubscriptionName = "",  
        [string]$dnsZoneRgName = '' 
#>

[CmdletBinding()]
param (
    [string]$storageAccountSubscriptionName = "",
    [string]$rgName = "",
    [string]$storageAccountName = "",
    [string]$vnetrg = "",
    [string]$vnetName = "",
    [string]$subnetName = '',
    [string]$dnsZoneSubscriptionName = "",  
    [string]$dnsZoneRgName = ''   

)
# Connect-AzAccount

$grouptypeid = @("queue")
foreach ($grouptype in $grouptypeid)
{
    Select-AzSubscription -Subscription $storageAccountSubscriptionName

    try{
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $rgName -Name $storageAccountName -ErrorAction Stop
    }
    catch {
        Write-Host $storageAccount.StorageAccountName "does not exist" -f Yellow
    }
    ## Create private endpoint connection. ##
    $parameters1 = @{
        Name = -join("pe-",$grouptype,"-",$storageAccountName)
        PrivateLinkServiceId = $storageAccount.ID
        GroupID = $grouptype
    }
    try {
        $privateEndpointConnection = New-AzPrivateLinkServiceConnection @parameters1 -ErrorAction Stop
    }
    catch {
        Write-Host "already exists"
        $_.Exception
    }
    


    ## Place virtual network into variable. ##
    #
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


    # ## Create private endpoint
    $parameters2 = @{
        ResourceGroupName = $rgName
        Name = -join("pe-",$grouptype,"-",$storageAccountName)
        Location = 'westus2'
        Subnet = $subnet
        PrivateLinkServiceConnection = $privateEndpointConnection
    }
    try {
        New-AzPrivateEndpoint @parameters2 -ErrorAction Stop
    }
    catch {
        Write-Host $parameters2.Name "failed to create" -ForegroundColor Yellow
        $_.Exception        
    }
    
    $privateEndPointName = -join("pe-",$grouptype,"-",$storageAccountName)

    try {
        $privateEndPoint = Get-AzPrivateEndpoint -Name $privateEndPointName
        $ipconfig = $privateEndPoint.CustomDnsConfigs
        Write-Output "ipconfig object: "$ipconfig
        $ipaddress = $ipconfig.IpAddresses
        Write-Output "ipaddress: " $ipaddress    
    }
    catch {
        Write-Host "failed to get the new private endpoint details" -ForegroundColor Yellow
        $_.Exception
    }
    

    ##############################################################################################
    ##############################################################################################
    
    ##############################################################################################
    ##############################################################################################    
    

    Select-AzSubscription -Subscription $dnsZoneSubscriptionName

    $privateZoneName = -join("privatelink.",$grouptype,".core.windows.net")
    $privateZoneName

    ## Create private dns zone. ##
    $parameters1 = @{
        ResourceGroupName = $dnsZoneRgName
        Name = $privateZoneName
    }
    try {
        $zone = Get-AzPrivateDnsZone @parameters1        
    }
    catch {
        Write-Host "failed to get the DNS ZOne:" $privateZoneName
    }
    

    ## Create dns network link. ##
    $parameters2 = @{
        ResourceGroupName = $dnsZoneRgName
        ZoneName = $zone.Name
        Name = -join($zone.Name,"-to-",$vnet.Name)
        VirtualNetworkId = $vnet.Id
    }
    $privateDnsVirtualNetworkLinkName = -join($zone.Name,"-to-",$vnet.Name)
    $checkExistingLink = Get-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $dnsZoneRgName -ZoneName $privateZoneName -Name $privateDnsVirtualNetworkLinkName
    if ($checkExistingLink.Name -ne $privateDnsVirtualNetworkLinkName)
    { 
        $link = New-AzPrivateDnsVirtualNetworkLink @parameters2
        $link
    }
    else
    {
        Write-Output $checkExistingLink.Name " already exists"
    }

    $checkDNSRecord = Get-AzPrivateDnsRecordSet -Name $storageAccountName -RecordType A -ZoneName $privateZoneName -ResourceGroupName $dnsZoneRgName
    if ($checkDNSRecord)
	{
		Remove-AzPrivateDnsRecordSet -zone $privateZoneName -name $storageAccountName -RecordType A
		[bool] $dnsRecordDeleted = $true
	}
	
	if ($dnsRecordDeleted)
    {
        Write-Output "Adding DNS record"
        New-AzPrivateDnsRecordSet  `
               -Name $storageAccountName `
               -RecordType A `
               -ZoneName $privateZoneName `
               -ResourceGroupName $dnsZoneRgName `
               -Ttl 3600 `
               -PrivateDnsRecords (New-AzPrivateDnsRecordConfig -IPv4Address $ipaddress)

     }
     else
     {
        Write-Output "DNS record already exists: " $checkDNSRecord.Name
     }
}