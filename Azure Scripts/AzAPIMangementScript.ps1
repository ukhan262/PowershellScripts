<#
    .SYNOPSIS
        This script is used to create an Azure API Management Service 
        within an existing or new resource group.

    .EXAMPLE
        .\AzAPIManagementScript.ps1 -sub "DemoSubscription" -orgName "TechCore" -adminEmail "umar@techcore.com" -rgName "rg-apim-techcore-pg" -apiMName "apim-cudirect-pg"  
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string] $sub = $(throw "$sub is required"),
    [Parameter()]
    [string] $orgName = $(throw "$orgName is required"),
    [Parameter()]
    [string] $adminEmail = $(throw "$adminEmail is required"),
    [Parameter()]
    [string] $rgName = $(throw "$rgName is required"),
    [Parameter()]
    [string] $apiMName = $(throw "$apiMName is required")
)

Connect-AzAccount

Import-Module -Name Az
Select-AzSubscription -Subscription $sub

<#
    Creating/Checking for resource group
#>
$resourceGroupName = $rgName
[bool] $rgExists = $false
try 
{
    $getAzResourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction Stop
    $getAzResourceGroup
    $rgExists = $true
}
catch
{
    $rgExists = $false
    Write-Host $resourceGroupName "does not exist" -ForegroundColor Yellow
}
if (!$rgExists)
{
    Write-Host $resourceGroupName "creating now" -ForegroundColor Blue
    $getAzResourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location WestUS2
    Write-Host $getAzResourceGroup.ResourceGroupName "has been created" -ForegroundColor Green
}

<#
    Creating/Checking for api management resource
#>
$apiManagementName = $apiMName
[bool] $apimExists = $false
try 
{
    $getApim = Get-AzApiManagement -Name $apiManagementName -ResourceGroupName $resourceGroupName -ErrorAction Stop
    $getApim
    $apimExists = $true
}
catch 
{
    $apimExists = $false
    Write-Host $apiManagementName "does not exist" -ForegroundColor Yellow
}
if(!$apimExists)
{
    Write-Host $apiManagementName "creating now" -ForegroundColor Blue
    $getApim = New-AzApiManagement `
                    -Name $apiManagementName `
                    -ResourceGroupName $resourceGroupName `
                    -Location WestUS2 `
                    -Organization $orgName `
                    -AdminEmail $adminEmail
    Write-Host $getApim.Name "has been created" -ForegroundColor Green
    $getApim
}


