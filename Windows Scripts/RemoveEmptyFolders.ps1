$tdc="foldername"
$dirs = Get-ChildItem $tdc -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | Select-Object -expandproperty FullName
$dirs | Foreach-Object { Remove-Item $_ }
