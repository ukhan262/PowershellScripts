# Client Id
$azureAplicationId = ""

# Tenant Id
$azureTenantId= ""

# Client Secret
$azurePassword = ConvertTo-SecureString "" -AsPlainText -Force

# Credential Object
$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)
Connect-AzAccount -Credential $psCred -TenantId $azureTenantId  -ServicePrincipal 