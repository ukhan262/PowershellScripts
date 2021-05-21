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
        .\AzMigrateResources.ps1 -sourceSub "NonProd-West" -sourceResourceGroup "rg-ent-eddms-qa2-01" -resourceType Microsoft.KeyVault/vaults -resourceName "kv-enterprise-qa-02" -destinationSub "NonProd-West" -destinationResourceGroup "rg-ent-commonapps-qa2-01"

    .EXAMPLE
        .\AzMigrateResources.ps1 -sourceSub "NonProd-West" -sourceResourceGroup "rg-commonapps-qa2-01" -resourceType Microsoft.DocumentDB/databaseAccounts -resourceName "cosdb-ent-tenant-sql-api-qa02" -destinationSub "NonProd-West" -destinationResourceGroup "rg-ent-commonapps-qa2-01"
        
    .EXAMPLE  
        .\AzMigrateResources.ps1 -sourceSub "NonProd-West" -sourceResourceGroup "rg-ent-edpn-qa2-01" -resourceType Microsoft.ServiceBus/namespaces -resourceName "sb-ent-events-qa2-101" -destinationSub "NonProd-West" -destinationResourceGroup "rg-ent-commonapps-qa2-01"
        
    .EXAMPLE
        .\AzMigrateResources.ps1 -sourceSub "IAC-West" -sourceResourceGroup "rg-crm-intuvo-test-dev-02" -resourceType Microsoft.Storage/storageAccounts -resourceName "examplesatest123" -destinationSub "IAC-West" -destinationResourceGroup "do-not-delete"
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string] $clientId = "",
    [Parameter()]
    [string] $tenantId = "",
    [Parameter()]
    [string] $clientSecretId = "",
    [Parameter(Mandatory)]
    [string] $sourceSub = "",
    [Parameter(Mandatory)]
    [string] $sourceResourceGroup = "",
    [Parameter(Mandatory)]
    [ValidateSet("Microsoft.ServiceBus/namespaces", "Microsoft.Storage/storageAccounts","Microsoft.DocumentDB/databaseAccounts", "Microsoft.KeyVault/vaults")]
    [string] $resourceType = "",
    [Parameter(Mandatory)]
    [string] $resourceName = "",
    [Parameter(Mandatory)]
    [string] $destinationSub = "",
    [Parameter(Mandatory)]
    [string] $destinationResourceGroup = ""
)

[bool] $useInteractiveLogin = $false
try {
    $clientSecret = ConvertTo-SecureString $clientSecretId -AsPlainText -Force
    $psCred = New-Object System.Management.Automation.PSCredential($clientId , $clientSecret)
    Connect-AzAccount -Credential $psCred -TenantId $tenantId -ServicePrincipal -ErrorAction Stop
}
catch {
    Write-Host "Failed to connect to the tenant using serice principal" -ForegroundColor Red
    $_.Exception
    $useInteractiveLogin = $true
}

if ($useInteractiveLogin)
{
    Connect-AzAccount
}

Select-AzSubscription -Subscription $sourceSub

[bool] $privateEndpointsExist = $false

try 
{
    $privateEndpoints = Get-AzPrivateEndpoint -ResourceGroupName $sourceResourceGroup -ErrorAction Stop
    $privateEndpointsExist = $true
}
catch 
{
    $_.Exception
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
        $_.Exception
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
    $_.Exception
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
        $_.Exception
        Write-Host "issues moving the resource" $resourceName -ForegroundColor Red
    }
    
}
