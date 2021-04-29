
$ErrorPreference = 'SilentlyContinue'

$user = ''
$MyPat = ''
$B64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(("{0}:{1}" -f $user,$MyPat)))

$h = @{
        'Authorization' = 'Basic ' + $B64Pat
      }

$response = Invoke-WebRequest -Uri "https://feeds.dev.azure.com/qlos/_apis/packaging/Feeds/QCommon/packages?api-version=6.0-preview.1" -Method 'GET' -Headers $h
$response_json = ($response.Content | ConvertFrom-Json) 

$response_json.value.name | Out-File .\packagename.txt
$response_json.value.versions.version | Out-File .\packageversion.txt
#$pkgName = $response_json.value.name
#$pkgVersion = $response_json.value.versions.version

#$pkgName | Merge $pkgVersion


$filePath = ".\.csv"
Import-Csv $filePath | `
ForEach-Object {
    Write-Host $_.PackageName, $_.PackageVersion
    $url = -join("https://pkgs.dev.azure.com/qlos/_apis/packaging/feeds/QCommon/nuget/packages/",$_.PackageName,"/versions/",$_.PackageVersion,"/content?api-version=6.1-preview.1")
    $fileLocation = -join(".\nugetpackages\",$_.PackageName,"_",$_.PackageVersion, ".nupkg")
    if (!(Test-Path $fileLocation))
    {
        Invoke-WebRequest -Uri $url -Method 'GET' -Headers $h -OutFile $fileLocation
    }
}





