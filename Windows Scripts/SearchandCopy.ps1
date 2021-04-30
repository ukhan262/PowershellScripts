$to = ''
$folderNames = 11,111,123;

foreach ($folder in $folderNames)
{
    Write-Output $folder;
    if (Test-Path "$folderLocation\$folder")
    {
        if (!(Test-Path $to\$folder\))
        {
            mkdir -Path $to\$folder\
        }

        Get-ChildItem "$folderLocation\$folder" -Filter *"assignment fe"* -Recurse | copy-item -Destination $to\$folder\ -Recurse
    }
}