Import-Module WebAdministration

$certLocation = ""
$siteName = ""
$sitePath = -join(".\Code\", $siteName, "\")
$certStoreLocation = "Cert:\LocalMachine\My"
$password = ''
$dnsName = "localhost"
$certFriendlyName = ""


#import the cert on the server
$cert = Get-ChildItem -Path $certStoreLocation `
            | Where-Object {$_.FriendlyName -Match $certFriendlyName}
if($cert.FriendlyName -eq $certFriendlyName)
{
    $cert
}
else
{
    Import-PfxCertificate `
        -FilePath $certLocation `
        -Password (ConvertTo-SecureString -String $password -AsPlainText -Force) `
        -CertStoreLocation $certStoreLocation
}

#create the sitePath if it does not exist
if (!(Test-Path $sitePath))
{
        md -Path $sitePath
}

#create website if it does not exist
$siteCheck = Get-Website -Name $siteName
if($siteCheck.name -eq $siteName)
{   
    Get-Website -Name $siteName   
}
else
{
  New-Website -Name $siteName -PhysicalPath $sitePath
  New-WebBinding -Name $siteName -IPAddress * -HostHeader $dnsName -Port 443 -Protocol https  
}

#add binding to the site          
$binding = Get-WebBinding -Name $siteName -Protocol https    
$binding.AddSslCertificate($cert.GetCertHashString(), "my")
$binding.certificateHash