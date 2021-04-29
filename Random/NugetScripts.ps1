nuget sources add -Name QCommon -Source "https://pkgs.dev.azure.com/cudirect/_packaging/QCommon/nuget/v3/index.json" -username "admin.ukhan@cudirect.com" -password "iaxg2bgkclotdznagjyyy3reafhv4zyp7mm3fzjbwliq6vx4hoka"
nuget.exe push -Source “https://pkgs.dev.azure.com/cudirect/_packaging/QCommon/nuget/v3/index.json” -ApiKey az “C:\Users\umar.khan\Downloads\cudirect.common.cache.1.2.428.nupkg”


nuget sources add -Name QCommon -Source "https://pkgs.dev.azure.com/qlos/_packaging/QCommon/nuget/v3/index.json" -username "admin.ukhan@cudirect.com" -password "iaxg2bgkclotdznagjyyy3reafhv4zyp7mm3fzjbwliq6vx4hoka"



# Example :
nuget.exe push -Source "https://qlos.pkgs.visualstudio.com/_packaging/CUDL-Feed/nuget/v3/index.json" -ApiKey az "C:\Users\chandran.shankar\Downloads\cudl.ssotoolkit.wrapper\cudl.ssotoolkit.wrapper\1.0.7\cudl.ssotoolkit.wrapper.1.0.7.nupkg"