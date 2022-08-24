# Terraform Format Recursive
function New-TFI { terraform init }
set-Alias -Name "tfi" -Value New-TFI

function New-TFIR { terraform init -reconfigure }
set-Alias -Name "tfir" -Value New-TFIR

function New-TFIU { terraform init -upgrade }
set-Alias -Name "tfiu" -Value New-TFIU

function New-TFP { terraform plan }
set-alias -Name "tfp" -Value New-TFP

function New-TFA { terraform apply }
set-alias -Name "tfa" -Value New-TFA

function New-TFAA { terraform apply -auto-approve }
set-alias -Name "tfap" -Value New-TFAA

function New-TFsl { terraform state list > statelist.txt}
set-alias -Name "tfsl" -Value New-TFsp

function New-TFsp { terraform state pull > statepull.txt}
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

