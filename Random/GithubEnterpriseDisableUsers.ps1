#please replace the username with the user that generates the PAT token
#example: 'umar:pat_tokn'
$Token = 'username:pat token value'
$Base64Token = [System.Convert]::ToBase64String([char[]]$Token);

$Headers = @{
    Authorization = 'Basic {0}' -f $Base64Token;
}

#put the name of the file where this exists
$FileLocation = '';

#this will be your URL for the internal github enterprise
$BaseUrl = 'https://github-organizationurl.com/api/v3'


Import-Csv $FileLocation | `
ForEach-Object{
    #this will be whatever the column name is in the excel sheet
    Write-host "making change for this user: " $_.username

    #setting up the api url
    $uri = -join($BaseUrl,"/users/",$_.username,"/suspended")

    $Body = @{
        username = $_.username;
        reason = 'disabling user for whatever reason';      
    } | ConvertTo-Json

    Invoke-RestMethod -Headers $Headers -Uri $uri -Body $Body -Method Put
}
 
