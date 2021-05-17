[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $azureTenantId = "",
    [Parameter(Mandatory)]
    [string]
    $azureAplicationId = "",
    [Parameter(Mandatory)]
    [string]
    $clientSecret = "",
    [Parameter(Mandatory)]
    [string]
    $keyVaultName = "",
    [Parameter(Mandatory)]
    [string]
    $certificateName = "",
    [Parameter(Mandatory)]
    [string]
    $certificatePath = "",
    [Parameter(Mandatory)]
    [string]
    $certificatePassword = ""
)


# Client Secret
$azurePassword = ConvertTo-SecureString $clientSecret -AsPlainText -Force

# Credential Object
$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)
Connect-AzAccount -Credential $psCred -TenantId $azureTenantId  -ServicePrincipal 

$keyVaultName = ""
$certificateName = ""
$certificatePath = ""

$Password = ConvertTo-SecureString -String $certificatePassword -AsPlainText -Force
Import-AzKeyVaultCertificate `
    -VaultName $keyVaultName `
    -Name $certificateName   `
    -FilePath $certificatePath `
    -Password $Password