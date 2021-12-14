

$tfeToken = ""

$Headers = @{
    Authorization  = "Bearer $tfeToken"
    "Content-Type" = "application/vnd.api+json"
}

$baseUrl = "https://app.terraform.io/api/v2/organizations/cudirect-namespace/workspaces"



$body = @{
    "page[size]"   = '5'
    "page[number]" = "1"
}

$response = Invoke-RestMethod -Uri $baseUrl -Headers $Headers -Body $body
$allWorkspaces = $response.data | select id, $_.attributes.name;
$allWorkspaces

foreach ($workspace in $allWorkspaces){

    $newurl = -join($baseUrl, "/", $workspace.id)
    $newurl
    Invoke-RestMethod -Uri $newurl -Headers $header
}

# ($response.data | select id).count