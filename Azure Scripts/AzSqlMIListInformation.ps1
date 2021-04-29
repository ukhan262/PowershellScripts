<#
    This script is used to get information about Azure SQL MI
#>

$subid = ''
$resourceGroup = ""
$instanceName = ""

Select-AzSubscription -Subscription $subid

$sqlInstace = Get-AzSqlInstance -Name $instanceName -ResourceGroupName $resourceGroup

$sqlInstace.ManagedInstanceName
$sqlInstace.StorageSizeInGB