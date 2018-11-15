#https://www.example-code.com/powershell/cert_export_private_key.asp

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "")]
param(
    [Parameter(Mandatory=$true)]
    [string]$SubjectName,

    [Parameter(Mandatory=$true)]
    [string]$Password
)    


$cert = New-SelfSignedCertificate -DnsName $SubjectName -CertStoreLocation "cert:\LocalMachine\My" `
             -KeyLength 2048 -KeySpec "KeyExchange"

$securePassword = ConvertTo-SecureString -String $Password -Force -AsPlainText

Export-PfxCertificate -Cert $cert -FilePath ".\$SubjectName.pfx" -Password $securePassword

#Export-Certificate -Type CERT -Cert $cert -FilePath ".\$SubjectName.cer"
 
