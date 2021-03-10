$Daysback = "-1"; 
$CurrentDate = Get-Date;
$DatetoDelete = $CurrentDate.AddDays($Daysback);
$ParentFolder = 'D:';
$Folders = Get-ChildItem $ParentFolder | 
               Where-Object {$_.PSIsContainer} | 
               Foreach-Object {$_.Name}


foreach ($f in $Folders){
    $Path = -join($ParentFolder,$f,'\_work');
    echo $Path;

    if (test-path $Path) {
        $NumDirs = Get-ChildItem -Path $Path | 
                       Where-Object { 
                                       $_.Name -match '^\d+$'-and
                                       $_.LastWriteTime -lt $DatetoDelete
                                    };
    
        $NumDirs | Remove-Item -Recurse -Force -Confirm:$false
    }
}