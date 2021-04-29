# this script must be run on the DNS server with correct permissions
# the CSV file must contain a column for AppName and then a column for IpAddress of the ASE that the app lives on

$fileLocation = ""
$zoneName = ""
Import-Csv $fileLocation | `
ForEach-Object {
    Add-DnsServerResourceRecordA `
        -Name $_.AppName `
        -ZoneName $zoneName `
        -AllowUpdateAny `
        -IPv4Address $_.IpAddress `
        -TimeToLive 00:10:00
}