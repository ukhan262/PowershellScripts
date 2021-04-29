$ErrorActionPreference = "SilentlyContinue"
Import-Module -Name Az
$Subscriptions = Get-AzSubscription
$reportName = "CUDirectVmsInfo.csv"
$report = @()

foreach ($sub in $Subscriptions){
    Select-AzSubscription -SubscriptionId $sub.SubscriptionId
    $vms = Get-AzVM
    $publicIps = Get-AzPublicIpAddress 
    $nics = Get-AzNetworkInterface | ?{ $_.VirtualMachine -NE $null} 
    foreach ($nic in $nics) {
        $info = "" | Select VmName, ResourceGroupName, Region, VmSize, VirtualNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress, NicName, ApplicationSecurityGroup
        $vm = $vms | ? -Property Id -eq $nic.VirtualMachine.id 
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
    }
$report | ft VmName, ResourceGroupName, Region, VmSize, VirtualNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress, NicName, ApplicationSecurityGroup | Out-File "C:\users\umar.khan\Documents\cudirectvms.txt"