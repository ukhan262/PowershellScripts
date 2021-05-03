<#
    .SYNOPSIS
        This script exports the details on all the users on what groups they 
        are part of inside the organizations.
        This uses az devops cli

    .DESCRIPTION
        This script requires couple of parameters
            - $PAT
            - $Organization
        Commands Used:
            - az devops login
            - az devops cpnfigure
            - az devops user list
            - az devops security group membership list

    .EXAMPLE
        .\CliDevOpsListUsers.ps1 -PAT "abcdefghijklmnopqrstuvwxyz" -Organization "https://dev.azure.com/organization"

#>
Param
(
    [Parameter(Mandatory)]
    [string]$PAT = $(throw "$PAT is required"),
    [Parameter(Mandatory)]
    [string]$Organization = $(throw "$Organization is required")
)

$UserGroups = @()

Write-Output $PAT | az devops login --org $Organization

az devops configure --defaults organization=$Organization

$allUsers = az devops user list --org $Organization | ConvertFrom-Json

foreach($au in $allUsers.members)
{
    $activeUserGroups = az devops security group membership list --id $au.user.principalName --org $Organization --relationship memberof | ConvertFrom-Json
    [array]$groups = ($activeUserGroups | Get-Member -MemberType NoteProperty).Name

    foreach ($aug in $groups)
    {
        $UserGroups += New-Object -TypeName PSObject -Property @{
                                            principalName=$au.user.principalName
                                            displayName=$au.user.displayName
                                            GroupName=$activeUserGroups.$aug.principalName
                                            }
    }
}
if (Test-Path .\UserGroups.json)
{
    Remove-Item .\UserGroups.json
}
if (Test-Path .\UserGroups.csv)
{
    Remove-Item .\UserGroups.csv
}
$UserGroups | ConvertTo-Json | Out-File -FilePath .\UserGroups.json
$UserGroups | ConvertTo-Csv | Out-File -FilePath .\UserGroups.csv