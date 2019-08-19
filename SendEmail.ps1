$EmailFrom = “sender”
$EmailTo = "recepient"
$Subject = “”
$Body = “”
$SMTPServer = “”
$Port = 587;
$Username = ""
$Password = ""
$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, $Port)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Username,$Password);
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
