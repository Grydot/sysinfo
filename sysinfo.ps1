# SysInfo - A minimalist system information tool for Windows. Created for my personal use.
#
# Author: Grydot
# Version: 1.0
#  
#

# Function to format memory size (bytes to GB)
function Format-MemorySize ($bytes) {
    $gb = [math]::Round($bytes / 1073741824, 2)  # Perform the calculation as a number
    return "$gb GB"  # Return the result with "GB" appended as a string
}

# Function to get local IP address (including network interfaces info)
function Get-NetworkInfo {
    $NetworkInterfaces = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "169.*"}  # Exclude APIPA addresses
    $NetworkInfo = ""
    foreach ($interface in $NetworkInterfaces) {
        $InterfaceName = $interface.InterfaceAlias
        $IPAddress = $interface.IPAddress
        $SubnetMask = $interface.PrefixLength
        $Gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Where-Object {$_.InterfaceAlias -eq $InterfaceName}).NextHop
        $DNSServers = (Get-DnsClientServerAddress -InterfaceAlias $InterfaceName).ServerAddresses -join ", "

        $NetworkInfo += "`n$InterfaceName - IP: $IPAddress/$SubnetMask, Gateway: $Gateway, DNS: $DNSServers"
    }
    return $NetworkInfo
}

# Function to get public IP address from ident.me
function Get-PublicIP {
    $PublicIP = (Invoke-RestMethod -Uri "https://ident.me" -Method Get).ToString()
    return $PublicIP
}

# Get system information
$ComputerInfo = Get-ComputerInfo
$OS = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption  # Use Caption for accurate OS name
$Architecture = $ComputerInfo.OSArchitecture
$UserName = $env:USERNAME
$HostName = $env:COMPUTERNAME
$CPU = (Get-CimInstance -ClassName Win32_Processor).Name

# Get total RAM and individual DIMM sizes
$TotalRAM = Format-MemorySize ((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory)
$DIMMs = Get-CimInstance -ClassName Win32_PhysicalMemory | ForEach-Object {
    Format-MemorySize $_.Capacity
}
$DIMMInfo = "(" + ($DIMMs -join ", ") + ")"

# Get all display adapters and their resolutions
$ResolutionInfo = Get-CimInstance -ClassName Win32_VideoController
$DisplayAdapters = ""
$GPUs = ""
$GPUIndex = 0

foreach ($adapter in $ResolutionInfo) {
    # Get the resolution
    $Width = $adapter.CurrentHorizontalResolution
    $Height = $adapter.CurrentVerticalResolution
    $Resolution = "$Width x $Height"
    
    # Display adapter info
    $DisplayAdapters += "$($adapter.Name): $Resolution`n"
    
    # GPU Info (memory and name)
    $GPUName = $adapter.Name
    $GPUMemory = Format-MemorySize $adapter.AdapterRAM
    $GPUs += "GPU ${GPUIndex}: $GPUName - $GPUMemory`n"
    
    # Increment GPU Index for next GPU
    $GPUIndex++
}

# Uptime
$Uptime = (Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime
$UptimeFormatted = "$($Uptime.Days)d $($Uptime.Hours)h $($Uptime.Minutes)m"

# Serial Number / Service Tag
$SerialNumber = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber

# Manufacturer
$Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer

# Public IP address
$PublicIP = Get-PublicIP

# Network Info (local IP, subnet mask, gateway, DNS)
$NetworkInfo = Get-NetworkInfo

# Disk Space Information
$Disks = Get-WmiObject Win32_LogicalDisk -Filter "DriveType = 3"  # Only local disks
$DiskInfo = ""
foreach ($disk in $Disks) {
    # Correctly calculate used space as Size - FreeSpace
    $UsedSpace = $disk.Size - $disk.FreeSpace
    $DiskInfo += "`n$($disk.DeviceID) - Total: $(Format-MemorySize $disk.Size), Used: $(Format-MemorySize $UsedSpace), Free: $(Format-MemorySize $disk.FreeSpace)"
}

# Battery Information (if available)
$Battery = Get-WmiObject -Class Win32_Battery
$BatteryInfo = ""
if ($Battery) {
    # Check charging status using BatteryStatus
    if ($Battery.BatteryStatus -eq 2) {
        $ChargingStatus = "Charging"
    } elseif ($Battery.BatteryStatus -eq 1) {
        $ChargingStatus = "Discharging"
    } else {
        $ChargingStatus = "Not Charging"
    }
    
    $BatteryInfo = "Battery: $($Battery.EstimatedChargeRemaining)% - $ChargingStatus"
} else {
    $BatteryInfo = "Battery: Not Available"
}

# Time Zone Information
$TimeZone = (Get-TimeZone).Id
$TimeZoneInfo = "Timezone: $TimeZone"

# Clock Information
$ClockInfo = Get-Date -Format "HH:mm:ss"
$Clock = "Clock: $ClockInfo"

# Display system information
Write-Host "System Information" -ForegroundColor Cyan
Write-Host "------------------" -ForegroundColor Cyan
Write-Host ("User:".PadRight(15) + $UserName) -ForegroundColor White
Write-Host ("Host:".PadRight(15) + $HostName) -ForegroundColor White
Write-Host ("Manufacturer:".PadRight(15) + $Manufacturer) -ForegroundColor White
Write-Host ("Serial #:".PadRight(15) + $SerialNumber) -ForegroundColor White
Write-Host ("OS:".PadRight(15) + $OS) -ForegroundColor White
Write-Host ("Architecture:".PadRight(15) + $Architecture) -ForegroundColor White
Write-Host ("CPU:".PadRight(15) + $CPU) -ForegroundColor White
Write-Host ("RAM:".PadRight(15) + "$TotalRAM $DIMMInfo") -ForegroundColor White

# Insert a blank line
Write-Host ""

# Display Disk Space
Write-Host ("Disk Space:".PadRight(15) + "$DiskInfo") -ForegroundColor White

# Insert a blank line
Write-Host ""

# Display Battery Info
Write-Host ("$BatteryInfo") -ForegroundColor White

# Insert a blank line
Write-Host ""

# Display Display Adapters and GPUs
Write-Host ("Display Adapters:".PadRight(15) + "`n$DisplayAdapters") -ForegroundColor White
Write-Host ("GPUs:".PadRight(15) + "`n$GPUs") -ForegroundColor White

# Display Public IP and Network Information
Write-Host ("Public IP:".PadRight(15) + $PublicIP) -ForegroundColor White
Write-Host ("Network Interfaces:".PadRight(15) + $NetworkInfo) -ForegroundColor White

# Insert a blank line
Write-Host ""

# Display Clock, Timezone, and Uptime at the bottom
Write-Host "$Clock" -ForegroundColor White
Write-Host "$TimeZoneInfo" -ForegroundColor White
Write-Host ("Uptime:".PadRight(15) + $UptimeFormatted) -ForegroundColor White
