<#
    This script is depended on a list of all the subscriptions.
    Required Value:
        - $reportName
    This script will export the information for all the VMs
#>
# Connect-AzAccount

$ErrorActionPreference = "SilentlyContinue"
Import-Module -Name Az

$reportName = ""
$fileName = ""

Import-Csv ".\$fileName.csv" |`
ForEach-Object{
    $reportName = $_.Name+".csv"
    Write-Host "Subscription Name:"$_.Name;
    Select-AzSubscription -Subscription $_.Name
    $report = @()
    $vms = Get-AzVM
    $publicIps = Get-AzPublicIpAddress 
    $nics = Get-AzNetworkInterface | Where-Object { $_.VirtualMachine -NE $null} 
    foreach ($nic in $nics) { 
        $info = "" | Select-Object VmName, ResourceGroupName, Region, VmSize, VirtualNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress, NicName, ApplicationSecurityGroup 
        $vm = $vms | Where-Object -Property Id -eq $nic.VirtualMachine.id 
        foreach($publicIp in $publicIps) { 
            if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
                $info.PublicIPAddress = $publicIp.ipaddress
                } 
            } 
            $info.OsType = $vm.StorageProfile.OsDisk.OsType 
            $info.VMName = $vm.Name 
            $info.ResourceGroupName = $vm.ResourceGroupName 
            $info.Region = $vm.Location 
            $info.VmSize = $vm.HardwareProfile.VmSize
            $info.VirtualNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3] 
            $info.Subnet = $nic.IpConfigurations.subnet.Id.Split("/")[-1] 
            $info.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress 
            $info.NicName = $nic.Name 
            $info.ApplicationSecurityGroup = $nic.IpConfigurations.ApplicationSecurityGroups.Id 
            $report+=$info 
        } 
    $report | Format-Table VmName, ResourceGroupName, Region, VmSize, VirtualNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress, NicName, ApplicationSecurityGroup 
    $report | Export-CSV ".\$reportName.csv"
}