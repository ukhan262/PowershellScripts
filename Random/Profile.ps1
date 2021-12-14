# Terraform Format Recursive
function New-TFI { terraform init }
set-Alias -Name "tfi" -Value New-TFI

function New-TFP { terraform plan }
set-alias -Name "tfp" -Value New-TFP

function New-TFA { terraform apply }
set-alias -Name "tfa" -Value New-TFA

function New-TFAA { terraform apply -auto-approve }
set-alias -Name "tfap" -Value New-TFAA

function New-TFsp { terraform state pull }
set-alias -Name "tfsp" -Value New-TFsp

function New-TFF { terraform fmt -recursive }
set-alias -Name "tff" -Value New-TFF

function New-GitA { git add .}
set-alias -Name "ga" -Value New-GitA

function New-GitC { git commit -m $args}
Set-Alias -Name "gmsg" -value New-GitC 

function New-GitPush { git push -u origin $args}
Set-Alias -Name "gpu" -Value New-GitPush

function New-GitCheckoutBranch { git checkout -b $args }
Set-Alias -Name "gcb" -Value New-GitCheckoutBranch

