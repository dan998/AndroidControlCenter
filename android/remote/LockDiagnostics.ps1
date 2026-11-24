# ==========================================================
# ANDROID CONTROL CENTER
# READ-ONLY ANDROID LOCK DIAGNOSTICS
# Requires: Authorized ADB connection
# Does not unlock, modify, or reset the device.
# ==========================================================

function Invoke-ACCReadOnlyAdb {
    param(
        [string]$AdbPath,
        [string]$Serial,
        [string[]]$Arguments
    )

    $output = @(& $AdbPath -s $Serial @Arguments 2>&1)
    $code = $LASTEXITCODE

    return [PSCustomObject]@{
        ExitCode = $code
        Output   = ($output -join "`n")
    }
}

function Get-ACCLockDiagnostics {
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

    $state = Invoke-ACCReadOnlyAdb $AdbPath $Serial @("get-state")

    if ($state.ExitCode -ne 0 -or $state.Output.Trim() -ne "device") {
        throw "Device is not connected and authorized through ADB."
    }

    $errors = @()

    $policy = Invoke-ACCReadOnlyAdb $AdbPath $Serial @(
        "shell", "dumpsys", "window", "policy"
    )

    $window = Invoke-ACCReadOnlyAdb $AdbPath $Serial @(
        "shell", "dumpsys", "window"
    )

    $power = Invoke-ACCReadOnlyAdb $AdbPath $Serial @(
        "shell", "dumpsys", "power"
    )

    $management = Invoke-ACCReadOnlyAdb $AdbPath $Serial @(
        "shell", "dumpsys", "device_policy"
    )

    $android = Invoke-ACCReadOnlyAdb $AdbPath $Serial @(
        "shell", "getprop", "ro.build.version.release"
    )

    $sdk = Invoke-ACCReadOnlyAdb $AdbPath $Serial @(
        "shell", "getprop", "ro.build.version.sdk"
    )

    $patch = Invoke-ACCReadOnlyAdb $AdbPath $Serial @(
        "shell", "getprop", "ro.build.version.security_patch"
    )

    $manufacturer = Invoke-ACCReadOnlyAdb $AdbPath $Serial @(
        "shell", "getprop", "ro.product.manufacturer"
    )

    $model = Invoke-ACCReadOnlyAdb $AdbPath $Serial @(
        "shell", "getprop", "ro.product.model"
    )

    $results = @(
        @{ Name = "Window policy"; Data = $policy }
        @{ Name = "Window state"; Data = $window }
        @{ Name = "Power state"; Data = $power }
        @{ Name = "Device management"; Data = $management }
        @{ Name = "Android version"; Data = $android }
        @{ Name = "SDK version"; Data = $sdk }
        @{ Name = "Security patch"; Data = $patch }
        @{ Name = "Manufacturer"; Data = $manufacturer }
        @{ Name = "Model"; Data = $model }
    )

    foreach ($item in $results) {
        if ($item.Data.ExitCode -ne 0) {
            $errors += "Could not retrieve $($item.Name)."
        }
    }

    $policyText = $policy.Output
    $windowText = $window.Output
    $powerText = $power.Output
    $managementText = $management.Output

    $keyguardShowing = $null
    $inputRestricted = $null
    $keyguardOccluded = $null
    $wakefulness = $null
    $failedAttempts = $null
    $failedGatekeeperAttempts = $null
    $deviceOwnerType = $null

    if ($windowText -match 'isKeyguardShowing=(true|false)') {
        $keyguardShowing = [bool]::Parse($Matches[1])
    }
    elseif ($policyText -match 'mShowingLockscreen=(true|false)') {
        $keyguardShowing = [bool]::Parse($Matches[1])
    }

    if ($policyText -match 'mInputRestricted=(true|false)') {
        $inputRestricted = [bool]::Parse($Matches[1])
    }

    if ($policyText -match 'mKeyguardOccluded=(true|false)') {
        $keyguardOccluded = [bool]::Parse($Matches[1])
    }

    if ($powerText -match 'mWakefulness=(Awake|Asleep|Dozing|Dreaming)') {
        $wakefulness = $Matches[1]
    }

    if ($managementText -match 'mFailedPasswordAttempts=(\d+)') {
        $failedAttempts = [int]$Matches[1]
    }

    if ($managementText -match 'mFailedPasswordAttemptsFromGateKeeper=(\d+)') {
        $failedGatekeeperAttempts = [int]$Matches[1]
    }

    if ($managementText -match 'Device Owner Type:\s*(-?\d+)') {
        $deviceOwnerType = [int]$Matches[1]
    }

    return [PSCustomObject]@{
        Serial                       = $Serial
        Manufacturer                 = $manufacturer.Output.Trim()
        Model                        = $model.Output.Trim()
        AndroidVersion               = $android.Output.Trim()
        SDK                          = $sdk.Output.Trim()
        SecurityPatch                = $patch.Output.Trim()
        KeyguardShowing              = $keyguardShowing
        InputRestricted              = $inputRestricted
        KeyguardOccluded             = $keyguardOccluded
        Wakefulness                  = $wakefulness
        FailedPasswordAttempts       = $failedAttempts
        FailedGatekeeperAttempts     = $failedGatekeeperAttempts
        DeviceOwnerType              = $deviceOwnerType
        RetrievedAt                  = Get-Date
        ReadOnly                     = $true
        Errors                       = @($errors)
    }
}
