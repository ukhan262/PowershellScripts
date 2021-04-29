$subscriptions = Get-AzSubscription

foreach($sub in $subscriptions)
{
    $reportName = $sub.Name+".csv"
    Select-AzSubscription -Subscription $sub
    Get-AzResource `
        | Where-Object Tags -eq $null `
        | Select-Object -Property Name, ResourceType `
        | Export-Csv "C:\Users\umar.khan\OneDrive - CU Direct Corporation\Documents\CUDirect Docs\NotTaggedPerSubscription\$reportName"

}