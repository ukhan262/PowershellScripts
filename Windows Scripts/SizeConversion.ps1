function Convert-Size {            
[cmdletbinding()]            
param(            
    [validateset("Bytes","KB","MB","GB","TB")]            
    [string]$From,            
    [validateset("Bytes","KB","MB","GB","TB")]            
    [string]$To,            
    [Parameter(Mandatory=$true)]            
    [double]$Value,            
    [int]$Precision = 4            
)            
switch($From) {            
    "Bytes" {$value = $Value }            
    "KB" {$value = $Value * 1024 }            
    "MB" {$value = $Value * 1024 * 1024}            
    "GB" {$value = $Value * 1024 * 1024 * 1024}            
    "TB" {$value = $Value * 1024 * 1024 * 1024 * 1024}            
}            
            
switch ($To) {            
    "Bytes" {return $value}            
    "KB" {$Value = $Value/1KB}            
    "MB" {$Value = $Value/1MB}            
    "GB" {$Value = $Value/1GB}            
    "TB" {$Value = $Value/1TB}            
            
}            
            
return [Math]::Round($value,$Precision,[MidPointRounding]::AwayFromZero)            
            
}            
     

# Connect-AzAccount
# Select-AzSubscription -Subscription "Production-West"

$getQueues = Get-AzServiceBusQueue -ResourceGroup rg-enterprise-prod-01 -NamespaceName prod-edpn-service-bus | Where-Object Name -eq "error"
foreach ($queue in $getQueues)
{
    Convert-Size -From Bytes -To GB -Value $queue.SizeInBytes 
}