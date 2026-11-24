# AndroidControlCenter - Samsung IMEI Reader
# Read-only inspection. No root, exploits, or security bypasses.
# Compatible with Windows PowerShell 5.1.

Set-StrictMode -Version Latest

function Get-ACCSamsungImei {
    [CmdletBinding()]
    param()

    $adbCommand = Get-Command adb -ErrorAction SilentlyContinue

    if (-not $adbCommand) {
        throw 'ADB is unavailable. Check that ADB is installed and in PATH.'
    }

    try {
        $deviceOutput = @(& $adbCommand.Source devices 2>$null)

        $authorized = @(
            $deviceOutput | Where-Object {
                $_ -match '^\s*(\S+)\s+device\s*$'
            }
        )

        if ($authorized.Count -eq 0) {
            throw 'No authorized ADB device found.'
        }

        if ($authorized.Count -gt 1) {
            throw 'Multiple authorized devices found. Connect only the intended device.'
        }

        $serial = (($authorized[0].Trim()) -split '\s+')[0]

        function Get-ACCProperty {
            param([string]$Property)

            $value = @(
                & $adbCommand.Source -s $serial shell getprop $Property 2>$null
            )

            if ($LASTEXITCODE -eq 0 -and $value.Count -gt 0) {
                return ([string]$value[0]).Trim()
            }

            return ''
        }

        $manufacturer = Get-ACCProperty 'ro.product.manufacturer'
        $model = Get-ACCProperty 'ro.product.model'
        $android = Get-ACCProperty 'ro.build.version.release'

        $multiSim = Get-ACCProperty 'persist.radio.multisim.config'
        $simStateRaw = Get-ACCProperty 'gsm.sim.state'
        $simCount = Get-ACCProperty 'ro.telephony.sim.count'

        $dualSimSupported = (
            $multiSim -match 'dsds|dsda' -or
            $simCount -match '^[2-9]$'
        )

        $simStates = @()

        if (-not [string]::IsNullOrWhiteSpace($simStateRaw)) {
            $simStates = @($simStateRaw -split ',')
        }

        $sim1State = 'Not exposed'
        $sim2State = 'Not exposed'

        if ($simStates.Count -ge 1) {
            $sim1State = $simStates[0].Trim()
        }

        if ($simStates.Count -ge 2) {
            $sim2State = $simStates[1].Trim()
        }

        [PSCustomObject]@{
            Connection       = 'Authorized'
            Manufacturer     = if ($manufacturer) { $manufacturer } else { 'Unknown' }
            Model            = if ($model) { $model } else { 'Unknown' }
            AndroidVersion   = if ($android) { $android } else { 'Unknown' }
            DualSimSupported = $dualSimSupported
            MultiSimConfig   = if ($multiSim) { $multiSim } else { 'Not exposed' }
            Sim1State        = $sim1State
            Sim2State        = $sim2State
            IMEI1            = 'Restricted / Not exposed'
            IMEI2            = 'Restricted / Not exposed'
            IMEIStatus       = 'Ordinary ADB does not expose the protected IMEI identifiers'
        }
    }
    catch {
        Write-Error "Samsung device inspection failed: $($_.Exception.Message)"
    }
}
