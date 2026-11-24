$ErrorActionPreference = "Stop"

try {
    $adbCommand = Get-Command adb -ErrorAction SilentlyContinue
    $adbPath = $null

    if ($adbCommand) {
        $adbPath = $adbCommand.Source
    }
    else {
        $localAdb = Join-Path (Split-Path $PSScriptRoot -Parent | Split-Path -Parent) "platform-tools\adb.exe"
        if (Test-Path $localAdb) {
            $adbPath = $localAdb
        }
    }

    if (-not $adbPath) {
        throw "ADB executable not found."
    }

    $deviceOutput = @(& $adbPath devices -l 2>&1)
    $devices = @()

    foreach ($line in $deviceOutput) {
        if ("$line" -match '^(\S+)\s+device(?:\s+(.*))?$') {
            $serial = $Matches[1]

            $model = (& $adbPath -s $serial shell getprop ro.product.model 2>$null | Out-String).Trim()
            $brand = (& $adbPath -s $serial shell getprop ro.product.manufacturer 2>$null | Out-String).Trim()
            $android = (& $adbPath -s $serial shell getprop ro.build.version.release 2>$null | Out-String).Trim()
            $batteryOutput = @(& $adbPath -s $serial shell dumpsys battery 2>$null)

            $battery = $null
            foreach ($batteryLine in $batteryOutput) {
                if ("$batteryLine" -match '^\s*level:\s*(\d+)') {
                    $battery = [int]$Matches[1]
                    break
                }
            }

            $connection = if ($serial -match ':\d+$') { "Wireless" } else { "USB / ADB" }

            $devices += [PSCustomObject]@{
                id = $serial
                manufacturer = $brand
                model = $model
                androidVersion = $android
                batteryLevel = $battery
                connection = $connection
                status = "Authorized"
            }
        }
    }

    [PSCustomObject]@{
        success = $true
        count = $devices.Count
        devices = @($devices)
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
    } | ConvertTo-Json -Depth 5 -Compress
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
