param([string] $artifactDirectory = '',
      [string] $systemWorkingDirectory = '',
      [string] $projectFolder = '',
      [string] $zippedArtifact = '')

$findCompiledFolder = ls $artifactDirectory\$projectFolder\ *PackageTmp* -Recurse -Directory;
$findConfigFile = Get-ChildItem -Path $systemWorkingDirectory\$projectFolder -Include *.config* -Recurse
$compiledContentFolder = ls $findCompiledFolder.PSPath;
$destinationFolder = -join($artifactDirectory, "\", $zippedArtifact, ".zip");

if (Test-Path $destinationFolder)
{
    Write-Host "removing existing artifact directory:"  $destinationFolder;
    Remove-Item $destinationFolder -Recurse -ErrorAction Ignore;
}

Write-Host "publishing artifacts for the project:" $projectFolder;
Compress-Archive -Path $compiledContentFolder.PSPath -DestinationPath $artifactDirectory\$zippedArtifact;
Compress-Archive -Path $findConfigFile -Update -DestinationPath $artifactDirectory\$zippedArtifact;