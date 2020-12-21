

param(
    [string] $serverInstance = "",
    [string] $database = "",
    [string] $username = "",
    [string] $password = "",
    [string] $sourceFolder = "",
    [string] $destFolder = "",
    [string] $stringToSearchFor = ""
)

$filesInFolder = ls $sourceFolder

$FlagsForScript = @()
foreach ($file in $filesInFolder){
    $fileName = $file.BaseName
    $destFolderLocation = -join($destFolder,$fileName,".txt")

    if (Test-Path $destFolderLocation)
    {
       Remove-Item $destFolderLocation -Force 
    }
    
    Write-Host "Executing:", $file
    Invoke-Sqlcmd -ServerInstance $serverInstance `
        -Database $database `
        -Username $username `
        -Password $password `
        -InputFile $file.FullName | Out-File $destFolderLocation

    
    $SEL = Select-String -Path $destFolderLocation -Pattern $stringToSearchFor
    
    Write-Host "==========================================================="
    
    if ($SEL -ne $null)
    {
        $SendEmailFlagPerScript = -join("SendEmail",$file.BaseName, ": Yes")
        $FlagsForScript += $SendEmailFlagPerScript
        Write-Host $file.BaseName, "contains", $SEL
        Write-Output "##vso[task.setvariable variable=SendEmailFlagPerScript;]$true"
        Write-Output "##vso[task.setvariable variable=SendEmailFlagPerScript;isOutput=true]$true"
    }
    else
    {
        $SendEmailFlagPerScript = -join("SendEmail",$file.BaseName, ": No")
        $FlagsForScript += $SendEmailFlagPerScript
        Write-Host $file.BaseName, "does not contains", $SEL
        Write-Output "##vso[task.setvariable variable=SendEmailFlagPerScript;]$false"
        Write-Output "##vso[task.setvariable variable=SendEmailFlagPerScript;isOutput=true]$false"
    }
    
}

Write-Host "==========================================================="
$FlagsForScript