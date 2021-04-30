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

$grouptypeid = @("blob","queue","table","file")
foreach ($grouptype in $grouptypeid)
{
    Select-AzSubscription -Subscription $storageAccountSubscriptionName

    $storageAccount = Get-AzStorageAccount -ResourceGroupName $rgName -Name $storageAccountName
    ## Create private endpoint connection. ##
    $parameters1 = @{
        Name = -join("pe-",$grouptype,"-",$storageAccountName)
        PrivateLinkServiceId = $storageAccount.ID
        GroupID = $grouptype
    }
    
    $privateEndpointConnection = New-AzPrivateLinkServiceConnection @parameters1


    ## Place virtual network into variable. ##
    #

    $vnet = Get-AzVirtualNetwork -ResourceGroupName $vnetrg -Name $vnetName

    ## Get Subnet into variable
    $subnet = $vnet | Select-Object -ExpandProperty subnets | Where-Object Name -eq $subnetName
    ## Disable private endpoint network policy ##
    $subnet.PrivateEndpointNetworkPolicies = "Disabled"
    $vnet | Set-AzVirtualNetwork

    # ## Create private endpoint
    $parameters2 = @{
        ResourceGroupName = $rgName
        Name = -join("pe-",$grouptype,"-",$storageAccountName)
        Location = 'westus2'
        Subnet = $subnet
        PrivateLinkServiceConnection = $privateEndpointConnection
    }
    New-AzPrivateEndpoint @parameters2
    $privateEndPointName = -join("pe-",$grouptype,"-",$storageAccountName)

    $privateEndPoint = Get-AzPrivateEndpoint -Name $privateEndPointName
    $ipconfig = $privateEndPoint.CustomDnsConfigs
    Write-Output "ipconfig object: "$ipconfig
    $ipaddress = $ipconfig.IpAddresses
    Write-Output "ipaddress: " $ipaddress    

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
    $zone = Get-AzPrivateDnsZone @parameters1

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
    }
    else
    {
        Write-Output $checkExistingLink.Name " already exists"
    }

    $checkDNSRecord = Get-AzPrivateDnsRecordSet -Name $storageAccountName -RecordType A -ZoneName $privateZoneName -ResourceGroupName $dnsZoneRgName
    if ($checkDNSRecord.Name -ne $storageAccountName)
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