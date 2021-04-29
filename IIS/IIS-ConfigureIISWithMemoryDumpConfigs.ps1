$appPoolNames = @("HelloWorld")

foreach ($appPool in $appPoolNames)
{
    $configSection="/system.applicationHost/applicationPools/add[@name='$appPool']/failure"
    Set-WebConfigurationProperty $configSection -name orphanWorkerProcess -value $true
    Set-WebConfigurationProperty $configSection -name orphanActionExe -value "c:\autodump\bin\dump.bat"
    Set-WebConfigurationProperty $configSection -name orphanActionParams -value "%1%"
}

iisreset /restart