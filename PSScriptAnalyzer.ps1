$psFolders = Get-ChildItem -Directory | Select-Object Name
foreach ($folder in $psFolders.Name)
{
  Push-Location $folder
  Write-Output "scanning the folder:" $folder;  
  Invoke-ScriptAnalyzer -Path *.ps1 -Recurse -Outvariable issues
  $errors   = $issues.Where({$_.Severity -eq 'Error'})
  $warnings = $issues.Where({$_.Severity -eq 'Warning'})
  if ($errors) {
      Write-Error "There were $($errors.Count) errors and $($warnings.Count) warnings total." -ErrorAction SilentlyContinue
  } else {
      Write-Output "There were $($errors.Count) errors and $($warnings.Count) warnings total."
  }
  Pop-Location
}