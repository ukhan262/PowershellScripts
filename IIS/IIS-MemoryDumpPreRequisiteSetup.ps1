$ErrorActionPreference = "SilentlyContinue"

#Step 1. Create folders
$folders = @("C:\windbg","C:\autodump","C:\autodump\dumps","C:\autodump\bin")

foreach ($folder in $folders)
{
    if (!(Test-Path $folder))
    {
        mkdir $folder
    }
    else
    {
        Write-Output "folder exists"
    }
}

#Step 2. Copy the bat file
$dumpfileDestinationLocation = "C:\autodump\bin\"

Get-ChildItem \\h-fileshare.cudirect.com\common\Umar\dump.bat | Copy-Item -Destination $dumpfileDestinationLocation
cd $dumpfileDestinationLocation; ls;

#Step 3. Modify permissions on folder
$folders = @("C:\autodump", "C:\autodump\dumps")
foreach ($folder in $folders)
{

    $ACL = Get-ACL -Path $folder
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","FullControl","Allow")
    $ACL.SetAccessRule($AccessRule)
    $ACL | Set-Acl -Path $folder
    (Get-ACL -Path $folder).Access | Format-Table IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -AutoSize
}


#Step 4. Copy debug folder
$debugFolderDestinationLocation = "C:\windbg\"
$debugFolderSourceLocation = ""

Get-ChildItem $debugFolderSourceLocation | Copy-Item -Destination $debugFolderDestinationLocation -Recurse -Force
Set-Location $debugFolderDestinationLocation; Get-ChildItem;

