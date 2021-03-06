﻿#must run as admin 

$WarningPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'
$DebugPreference='Continue'


$pfxPath = ".\certificate.pfx"
$pfxPassword = ''
$fileLocation = ".\Target Servers.csv"
$thumbprint = ""


Import-Csv $fileLocation | `
ForEach-Object{
    Select-AzSubscription -SubscriptionId $_.SubscriptionId

    $fqdn_new = -join($_.AppName, ".origence.local")
    
    Write-Output "setting custom domain" $_.AppName
    
    Set-AzWebApp -Name $_.AppName -ResourceGroupName $_.ResourceGroupName `
        -HostNames @($fqdn_new)
        
    
    Write-Output "setting cert" $_.AppName
    
    New-AzWebAppSSLBinding -WebAppName $_.AppName -ResourceGroupName $_.ResourceGroupName -Name $fqdn_new `
        -CertificateFilePath $pfxPath `
        -CertificatePassword $pfxPassword `
        -SslState SniEnabled

    New-AzWebAppSSLBinding -WebAppName $_.AppName -ResourceGroupName $_.ResourceGroupName -Name $fqdn_new  `
        -Thumbprint $thumbprint       
   
}

#Common Subscription because DNS zone is in a different subscription
$commonSub = ""
$commonDNSRG = ""
Select-AzSubscription -SubscriptionId $commonSub

Import-Csv $fileLocation | `
ForEach-Object{
    try {
        Write-Output "adding DNS record for " $_.AppName

        New-AzPrivateDnsRecordSet  `
            -Name $_.AppName `
            -RecordType A `
            -ZoneName origence.local `
            -ResourceGroupName $commonDNSRG `
            -Ttl 3600 `
            -PrivateDnsRecords (New-AzPrivateDnsRecordConfig -IPv4Address $_.IpAddress)
    
        Write-Output "DNS recorded added successfully for " $_.AppName   
    }
    catch {
        Write-Output "dns zone not added"
    }  
}