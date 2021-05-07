<#
    .SYNOPSIS
        This script is used to migrate resources from one subscription to another or
        within the same subscription from one resource group to another.

    .DESCRIPTION
        This script requires couple of parameters
            - $clientId
            - $tenantId
            - $clientSecretId
            - $sourceSub
            - $sourceResourceGroup
            - $resourceType
            - $resourceName
            - $destinationResourceGroup
            - $destinationSub

        Commands Used:
            - Select-AzSubscription
            - Get-AzPrivateEndpoint
            - Remove-AzResource
            - Get-AzResource
            - Move-AzResource
        
        Explanation:
            - Private Endpoints are deleted because they can't be migrated
            - Resources are moved

    .EXAMPLE
        .\AzMigrateResources.ps1 -clientId "" -tenantId "" -clientSecret "" -sourceSub "sourceSubName" -sourceResourceGroup "rgName" -resourceType Microsoft.KeyVault/vaults -resourceName "kv-migration-sbx-01" -destinationSub "destSubName" -destinationResourceGroup "destRgName"

    .EXAMPLE
        .\AzMigrateResources.ps1 -clientId "" -tenantId "" -clientSecret "" -sourceSub "sourceSubName" -sourceResourceGroup "rgName" -resourceType Microsoft.DocumentDB/databaseAccounts -resourceName "cosdb-migration-sbx-01" -destinationSub "destSubName" -destinationResourceGroup "destRgName"
    
    .EXAMPLE
        .\AzMigrateResources.ps1 -clientId "" -tenantId "" -clientSecret "" -sourceSub "NonProd-West" -sourceResourceGroup "rg-ent-eddms-dev-01" -resourceType Microsoft.Storage/storageAccounts -resourceName "stenteddmsdev01" -destinationSub "NonProd-West" -destinationResourceGroup "rg-ent-eddms-dev-01"

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $clientId = "",
    [Parameter(Mandatory)]
    [string] $tenantId = "",
    [Parameter(Mandatory)]
    [string] $clientSecretId = "",
    [Parameter(Mandatory)]
    [string] $sourceSub = "",
    [Parameter(Mandatory)]
    [string] $sourceResourceGroup = "",
    [Parameter(Mandatory)]
    [ValidateSet("Microsoft.Storage/storageAccounts","Microsoft.DocumentDB/databaseAccounts", "Microsoft.KeyVault/vaults")]
    [string] $resourceType = "",
    [Parameter(Mandatory)]
    [string] $resourceName = "",
    [Parameter(Mandatory)]
    [string] $destinationSub = "",
    [Parameter(Mandatory)]
    [string] $destinationResourceGroup = ""
)

$clientSecret = ConvertTo-SecureString $clientSecretId -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($clientId , $clientSecret)
Connect-AzAccount -Credential $psCred -TenantId $tenantId -ServicePrincipal

Select-AzSubscription -Subscription $sourceSub

[bool] $privateEndpointsExist = $false

try 
{
    $privateEndpoints = Get-AzPrivateEndpoint -ResourceGroupName $sourceResourceGroup -ErrorAction Stop
    $privateEndpointsExist = $true
}
catch 
{
    $privateEndpointsExist = $false
    Write-Host "no private endpoints found in the resource group" $sourceResourceGroup -ForegroundColor Yellow
}

if ($privateEndpoints)
{
    try
    {
        $privateLinkServiceConnections = $privateEndpoints.PrivateLinkServiceConnections

        if($privateLinkServiceConnections.PrivateLinkServiceId -like '*$resourceName*')
        {
            $privateEndpointResourceId = $privateEndpoints.Id
            $privateEndpointResourceId
            Remove-AzResource -privateEndpointResourceId $privateEndpointResourceId -Force -ErrorAction Stop
        }
    }
    catch{
        Write-Host "issues moving the resource" $privateEndpointResourceId -ForegroundColor Red  
    }
}

[bool] $resourceExists = $false

try
{
    $resources = Get-AzResource -ResourceGroupName $sourceResourceGroup -ResourceType $resourceType | Where-Object Name -Like "*$resourceName*" -ErrorAction Stop
    $resources.ResourceId
    $resourceExists = $true
}
catch 
{
    $resourceExists = $false
    Write-Host $resourceName "does not exist" -ForegroundColor Red
}

if ($resourceExists)
{
    if ($sourceSub -ne $destinationSub)
    {
        Select-AzSubscription -Subscription $destinationSub
    }
    try
    {
        Move-AzResource -ResourceId $resources.ResourceId -DestinationResourceGroupName $destinationResourceGroup -Force -ErrorAction Stop 
    }
    catch
    {
        Write-Host "issues moving the resource" $resourceName -ForegroundColor Red
    }
    
}
