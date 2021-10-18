Set-Item WSMan:\localhost\Service\Auth\Basic -Value $False
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $False
winrm delete winrm/config/listener?address=*+transport=HTTP
Stop-Service -force winrm
Set-Service -Name winrm -StartupType Disabled