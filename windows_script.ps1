Install-WindowsFeature -Name Web-Server,Web-WebSockets,Web-Asp-Net,Web-Asp-Net45,Web-Mgmt-Console
Import-Module -Name ServerManager
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Import-Module -Name WebAdministration
$Cert = New-SelfSignedCertificate -dnsName "<Server FQDN>" -CertStoreLocation cert:\LocalMachine\My -KeyLength 2048 -NotAfter (Get-Date).AddYears(1)
$x509 = 'System.Security.Cryptography.X509Certificates.X509Store'
$Store = New-Object -TypeName $x509 -ArgumentList 'Root','LocalMachine'
$Store.Open('ReadWrite')
$store.Add($Cert)
$Store.Close()
New-WebBinding -Name "Default Web Site" -protocol https -port 443
$Cert | New-Item -path IIS:\SslBindings\0.0.0.0!443
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Install-WindowsFeature -Name 'DHCP' -IncludeManagementTools
Add-DhcpServerV4Scope -Name "Worker" -StartRange 192.168.113.1 -EndRange 192.168.113.70 -SubnetMask 255.255.255.128
Set-DhcpServerV4OptionValue -Router 192.168.113.79
Restart-service dhcpserver
PAUSE