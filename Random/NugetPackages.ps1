cd "C:\users\umar.khan\downloads\"

#c.\nuget.exe sources add -Name QCommon2 -Source "https://pkgs.dev.azure.com/cudirect/_packaging/QCommon/nuget/v3/index.json" -username "admin.ukhan@cudirect.com" -password "iaxg2bgkclotdznagjyyy3reafhv4zyp7mm3fzjbwliq6vx4hoka"


$packages = Get-ChildItem -Filter *".nupkg"* | Select-Object Name
# $packages


foreach ($pkg in $packages.Name){
     #$pkg
     $pkgLocation = -join("""",".\",$pkg,"""")
     $pkgLocation
     
     
     .\nuget.exe push -Source “https://pkgs.dev.azure.com/cudirect/_packaging/QCommon/nuget/v3/index.json” -ApiKey az $pkgLocation
     
     
 }

.\nuget.exe push -Source "https://pkgs.dev.azure.com/cudirect/_packaging/Common/nuget/v3/index.json" -ApiKey az ".\NugetPackages\CUDC.DataProtection.Core.Autofac_3.0.97.nupkg"


