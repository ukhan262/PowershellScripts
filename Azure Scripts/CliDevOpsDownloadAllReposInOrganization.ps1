$WarningPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

param(
    [string]$Organization = "CloudiFyiSolutions"
)

if ($Organization -notmatch '^https?://dev.azure.com/\w+') {
    $Organization = "https://dev.azure.com/$Organization"
}

az devops login
# Make sure we are signed in to Azure
$AccountInfo = az account show 2>&1
try {
    $AccountInfo = $AccountInfo | ConvertFrom-Json -ErrorAction Stop
}
catch {
    az login --allow-no-subscriptions
}

# Make sure we have Azure DevOps extension installed
$DevOpsExtension = az extension list --query '[?name == ''azure-devops''].name' -o tsv
if ($null -eq $DevOpsExtension) {
    $null = az extension add --name 'azure-devops'
}

$Projects = az devops project list --organization $Organization --query 'value[].name' -o tsv
$Projects
foreach ($Proj in $Projects) {
    if (-not (Test-Path -Path ".\$Proj" -PathType Container)) {
        New-Item -Path $Proj -ItemType Directory |
        Select-Object -ExpandProperty FullName |
        Push-Location
    }
    $Repos = az repos list --organization $Organization --project $Proj | ConvertFrom-Json
    write-host "printing all the repos";
    $Repos
    foreach ($Repo in $Repos) {
        cd $Proj
        # mkdir $Repo.name
            Write-Output "Cloning repo $Proj\$($Repo.Name)"
            git clone $Repo.webUrl
            cd ..;
        
    }
}
