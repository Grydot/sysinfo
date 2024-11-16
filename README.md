# sysinfo
Minimalist System Information Tool Written in Powershell

Created for my personal use with MDM. I will add stuff as I need it unless you make a request. Will output all info similar to example below.

Depending on your environment and setup you may need to change your execution policy to run script.

```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

```
System Information
------------------
User:          Grydot
Host:          BLACKOUT
Manufacturer:  Dell Inc.
Serial #:      ABC1234
OS:            Microsoft Windows 10 Pro
Architecture:  64-bit
CPU:           Intel(R) Core(TM) i5-8365U CPU @ 1.60GHz
RAM:           7.78 GB (8 GB)

Disk Space:    
C: - Total: 237.82 GB, Used: 74.66 GB, Free: 163.16 GB

Battery: 97% - Discharging

Display Adapters:
Parsec Virtual Display Adapter:  x 
Intel(R) UHD Graphics 620: 1920 x 1080

GPUs:          
GPU 0: Parsec Virtual Display Adapter - 0 GB
GPU 1: Intel(R) UHD Graphics 620 - 1 GB

Public IP:     0.0.0.0
Network Interfaces:
Wi-Fi - IP: 10.0.0.2/24, Gateway: 10.0.0.1, DNS: 8.8.8.8, 8.8.4.4

Clock: 13:04:47
Timezone: Eastern Standard Time
Uptime:        19d 1h 16m
```
