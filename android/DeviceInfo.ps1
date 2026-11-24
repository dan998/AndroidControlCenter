# ==========================================================
# ANDROID CONTROL CENTER
# UNIVERSAL ANDROID DEVICE INFORMATION
# Requires: Authorized ADB connection
# Read-only: Does not modify the Android device
# ==========================================================

function Get-ACCAndroidProperty {
    param(
        [string]$AdbPath,
        [string]$Serial,
        [string]$Property
    )

    $result = @(& $AdbPath -s $Serial shell getprop $Property 2>&1)
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        return $null
    }

    $value = ($result -join "`n").Trim()

    if ([string]::IsNullOrWhiteSpace($value)) {
        return $null
    }

    return $value
}

function Get-ACCAndroidDeviceInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AdbPath,

        [Parameter(Mandatory = $true)]
        [string]$Serial
    )

    if (!(Test-Path -LiteralPath $AdbPath -PathType Leaf)) {
        throw "ADB executable not found: $AdbPath"
    }

    if ([string]::IsNullOrWhiteSpace($Serial)) {
        throw "A device serial is required."
    }

    $state = @(& $AdbPath -s $Serial get-state 2>&1)
    $stateCode = $LASTEXITCODE
    $deviceState = ($state -join " ").Trim()

    if ($stateCode -ne 0 -or $deviceState -ne "device") {
        return [PSCustomObject]@{
            Serial       = $Serial
            Available    = $false
            Status       = $deviceState
            Manufacturer = $null
            Brand        = $null
            Model        = $null
            Device       = $null
            Product      = $null
            Android      = $null
            SDK          = $null
            Build        = $null
            Fingerprint  = $null
            BatteryLevel = $null
            BatteryStatus = $null
            Connection   = if ($Serial -match ':\d+$') {
                "Network (inferred)"
            } else {
                "USB / Other (inferred)"
            }
            RetrievedAt  = Get-Date
            Errors       = @("Device is not authorized or available through ADB.")
        }
    }

    $errors = @()

    $properties = [ordered]@{
        Manufacturer = "ro.product.manufacturer"
        Brand        = "ro.product.brand"
        Model        = "ro.product.model"
        Device       = "ro.product.device"
        Product      = "ro.product.name"
        Android      = "ro.build.version.release"
        SDK          = "ro.build.version.sdk"
        Build        = "ro.build.display.id"
        Fingerprint  = "ro.build.fingerprint"
    }

    $info = @{}

    foreach ($item in $properties.GetEnumerator()) {
        try {
            $info[$item.Key] = Get-ACCAndroidProperty `
                -AdbPath $AdbPath `
                -Serial $Serial `
                -Property $item.Value

            if (!$info[$item.Key]) {
                $errors += "Unable to retrieve $($item.Key)."
            }
        }
        catch {
            $info[$item.Key] = $null
            $errors += "Failed to retrieve $($item.Key): $($_.Exception.Message)"
        }
    }

    $batteryLevel = $null
    $batteryStatus = "Unknown"

    try {
        $batteryOutput = @(
            & $AdbPath -s $Serial shell dumpsys battery 2>&1
        )
        $batteryCode = $LASTEXITCODE
        $batteryText = $batteryOutput -join "`n"

        if ($batteryCode -eq 0) {
            if ($batteryText -match '(?m)^\s*level:\s*(\d+)') {
                $batteryLevel = [int]$Matches[1]
            }

            if ($batteryText -match '(?m)^\s*status:\s*(\d+)') {
                switch ([int]$Matches[1]) {
                    2 { $batteryStatus = "Charging" }
                    3 { $batteryStatus = "Discharging" }
                    4 { $batteryStatus = "Not charging" }
                    5 { $batteryStatus = "Full" }
                    default { $batteryStatus = "Unknown" }
                }
            }
        }
        else {
            $errors += "Unable to retrieve battery information."
        }
    }
    catch {
        $errors += "Battery check failed: $($_.Exception.Message)"
    }

    $connection = if ($Serial -match ':\d+$') {
        "Network (inferred)"
    } else {
        "USB / Other (inferred)"
    }

    return [PSCustomObject]@{
        Serial        = $Serial
        Available     = $true
        Status        = "Connected"
        Manufacturer  = $info.Manufacturer
        Brand         = $info.Brand
        Model         = $info.Model
        Device        = $info.Device
        Product       = $info.Product
        Android       = $info.Android
        SDK           = $info.SDK
        Build         = $info.Build
        Fingerprint   = $info.Fingerprint
        BatteryLevel  = $batteryLevel
        BatteryStatus = $batteryStatus
        Connection    = $connection
        RetrievedAt   = Get-Date
        Errors        = @($errors)
    }
}
