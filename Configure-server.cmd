chcp 65001
net localgroup "Пользователи удаленного управления" zenith\a-PSRemoting /add
subinacl.exe /service %1 /grant=zenith\a-PSRemoting=F
pause