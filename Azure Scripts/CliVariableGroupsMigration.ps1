# Make sure we have Azure DevOps extension installed
$DevOpsExtension = az extension list --query '[?name == ''azure-devops''].name' -o tsv
if ($null -eq $DevOpsExtension) {
    $null = az extension add --name 'azure-devops'
}

<#
    This script will export the variables from a variable group 
    and will be used to migrate to a different prject and organization.
#>
$org = ""
$project = ""
$groupid = ""
$filename = ""

az devops login --organization $org;

az pipelines variable-group variable list `
    --group-id $groupid `
    --project $project `
    --output table `
    | Export-csv ".\$filename.csv"