$Daysback = "0";
$CurrentDate = Get-Date;
$DatetoDelete = $CurrentDate.AddDays($Daysback);
$ParentFolder = 'c:\azagent\';
$Folders = Get-ChildItem $ParentFolder |
               Where-Object {$_.PSIsContainer} |
               Foreach-Object {$_.Name}

foreach ($f in $Folders){
    $Path = -join($ParentFolder,$f,'\_work');
    Write-Output $Path;
    
    if (test-path $Path) {
        $NumDirs = Get-ChildItem -Path $Path |
                       Where-Object {
                                       ($_.Name -match '^\d+$'-or $_.Name -clike 'r*') -and
                                       $_.LastWriteTime -lt $DatetoDelete
                                    };
        #$NumDirs
        $NumDirs | Remove-Item -Recurse -Force -Confirm:$false
    }
}