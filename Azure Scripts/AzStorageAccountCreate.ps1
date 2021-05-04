<#
    .SYNOPSIS
        This script is used to migrate resources from one subscription to another or
        within the same subscription from one resource group to another.

    .DESCRIPTION
        This script requires couple of parameters
            - $clientid
            - $tenantid
            - $clientSecretId
            - $subscription
            - $resourceGroupName
            - $storageAccountName
        Commands Used:
            - Select-AzSubscription
            - Get-AzStorageAccount
            - New-AzStorageAccount
        
        Explanation:
            - Storage Account is being created

    .EXAMPLE
        .\AzStorageAccountCreate.ps1 -clientid "app id " -tenantid "tenant id" -clientSecretId "client secret" -subscription "subN ame" -resourceGroupName "rg name" -storageAccountName "storage account name"
#>
Param
(
    [Parameter(Mandatory)]
    [string]$clientid = $(throw "$clientid is required"),
    [Parameter(Mandatory)]
    [string]$tenantid = $(throw "$tenantid is required"),
    [Parameter(Mandatory)]
    [string]$clientSecretId = $(throw "$clientSecretId is required"),
    [Parameter(Mandatory)]
    [string]$subscription = $(throw "$subscription is required"),
    [Parameter(Mandatory)]
    [string]$resourceGroupName = $(throw "$resourceGroupName is required"),
    [Parameter(Mandatory)]
    [string]$storageAccountName = $(throw "$storageAccountName is required")
)

$clientSecret = ConvertTo-SecureString $clientSecretId -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($clientId , $clientSecret)
Connect-AzAccount -Credential $psCred -TenantId $tenantId -ServicePrincipal

Select-AzSubscription -Subscription $subscription

[bool] $storageAccountExists = $false
try
{
    $getStorageAccount = Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName -ErrorAction Stop
    $storageAccountExists = $true
    Write-host $storageAccountName "already exists with in resource group" $getStorageAccount.ResourceGroupName -ForegroundColor Yellow
}
catch
{
    Write-host $storageAccountName "does not exist" -ForegroundColor DarkYellow
    $storageAccountExists = $false
}

if (!$storageAccountExists)
{
    try
    {
        Write-Host $storageAccountName "is being created" -ForegroundColor White

        $newStorageAccount = New-AzStorageAccount -Location westus2 -Name $storageAccountName -ResourceGroupName $resourceGroupName -SkuName Standard_GRS -AccessTier Hot -AllowBlobPublicAccess $false -AllowSharedKeyAccess $false -PublishMicrosoftEndpoint $false -Kind StorageV2 -MinimumTlsVersion TLS1_2 -ErrorAction Stop
        $newStorageAccount.Id

        Write-Host $storageAccountName "created" -ForegroundColor Green
    }
    catch
    {
        Write-Host "failed to create" $storageAccountName -ForegroundColor Red
    }
} 

