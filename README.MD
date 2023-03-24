# RestartService
Перезапуск определенных сервисов на серверах

Требования: 
1. Включить на сервере PSremoting
2. Добавить в группу "Пользователи удаленного управления на сервере"
3. Выдать права этой группе на службу на сервере
   ```
   subinacl.exe /service SERVICE_NAME /grant=zenith\a-PSRemoting=F
   ```

Все эти действия завернуты в скрипт 
```
Configure-server.cmd "SERVICENAME"
```