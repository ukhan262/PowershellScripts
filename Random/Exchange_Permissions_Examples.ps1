#Creating a new mailbox
$password = (get-Credential).Password

New-Mailbox -Name '' -Alias '' -OrganizationalUnit '' -UserPrincipalName '' -SamAccountName '' -FirstName '' -Initials '' -LastName '' -Password  $password -ResetPasswordOnNextLogon $false -Database '' -RetentionPolicy ''

#Full Mailbox Permission
Add-MailboxPermission -Identity "PermissionGivenOn" -User "PermissionGivenTo" -AccessRights FullAccess -InheritanceType all

#Full Mailbox Permission W/O AutoMapping
Add-MailboxPermission -Identity "PermissionGivenOn" -User 'PermissionGivenTo' -AccessRights FullAccess -InheritanceType All -Automapping $false

#Remove Full Mailbox Permission
Remove-MailboxPermission -Identity "PermissionTakenOn" -User "PermissionTakenFrom" -AccessRights FullAccess -InheritanceType all

#Send as Permissions
Add-ADPermission "PermissionGivenOn" -User "PermissionGivenTo" -Extendedrights "Send As"

#Add Dist. Group Members
Add-DistributionGroupMember -Identity "Group Name" -Members "abc@test.com, xyz@test.com"

#Linking Mailboxes Under Same Forest
New-Mailbox -Name 'Tester Account' -Alias 'testeraccount' -OrganizationalUnit '' -UserPrincipalName 'testeraccount@wedgewood-inc.com' -SamAccountName 'testeraccount' -FirstName 'Tester' -Initials '' -LastName 'Account' -Database '' -LinkedMasterAccount '' -LinkedDomainController '' -LinkedCredential:(Get-Credential account)  

#New Dist. Group
new-DistributionGroup -Name 'Group Name' -Type 'Distribution' -OrganizationalUnit '' -SamAccountName '' -Alias '' 

#Public Folder Permissions
Add-PublicFolderClientPermission -Identity "PermissionGivenOn" -AccessRights PublishingEditor -User PermissionGivenTo

#Calendar Folder Permissions
Add-MailboxFolderPermission -Identity PermissionGivenOn:\Calendar -User PermissionGivenTo -AccessRights Editor

#Viewing the Entire Forest
Set-AdServerSettings -ViewEntireForest $true

#Enabling Mailbox on a User
Enable-Mailbox -Identity '' -Alias '' -Database '' -RetentionPolicy ''

#Changing SMTP
Set-Mailbox identity -EmailAddresses newemailaddress -EmailAddressPolicyEnabled $false

#Email Forwarding
Set-Mailbox -Identity "ForwardingOn" -DeliverToMailboxAndForward $true -ForwardingSMTPAddress "ForwardingTo"

#Mailbox Statistics
Get-MailboxStatistics -Server "mailserver" | Select DisplayName, ItemCount, TotalItemSize | Sort-Object TotalItemSize -Descending | Export-CSV c:\mbsizes.csv 




