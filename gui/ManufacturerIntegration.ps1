. "$PSScriptRoot\SamsungPanel.ps1"
. "$PSScriptRoot\UniversalPanel.ps1"
. "$PSScriptRoot\RecoveryPanel.ps1"
. "$PSScriptRoot\ManufacturerTabs.ps1"
. "$PSScriptRoot\..\android\remote\LockDiagnostics.ps1"

function Add-ACCManufacturerIntegration {
    param(
        [System.Windows.Forms.Form]$Form,
        [System.Windows.Forms.ComboBox]$DeviceSelector,
        [string]$AdbPath
    )

    $tabs = New-ACCManufacturerTabs -Parent $Form
    $universalPage = $tabs.TabPages | Where-Object Text -eq "Universal"
    $samsungPage = $tabs.TabPages | Where-Object Text -eq "Samsung"
    $recoveryPage = $tabs.TabPages | Where-Object Text -eq "Recovery Center"

    $universalHost = $universalPage.Controls | Select-Object -First 1
    $samsungHost = $samsungPage.Controls | Select-Object -First 1
    $recoveryHost = $recoveryPage.Controls | Select-Object -First 1

    $existingControls = @(
        $Form.Controls | Where-Object {
            $_ -ne $tabs -and $_.Top -ge 300 -and $_.Top -lt 705
        }
    )

    foreach ($control in $existingControls) {
        $oldLeft = $control.Left
        $newTop = $control.Top - 305
        $control.Parent = $universalHost
        $control.Location = New-Object System.Drawing.Point($oldLeft, $newTop)
    }

    $adbExecutable = $AdbPath
    $deviceControl = $DeviceSelector

    $samsungPanel = New-ACCSamsungPanel -Parent $samsungHost
    $samsungOutput = $samsungPanel.Output

    $samsungPanel.RunButton.Add_Click({
        $serial = [string]$deviceControl.SelectedItem

        if ([string]::IsNullOrWhiteSpace($serial)) {
            $samsungOutput.Text = "No authorized device is selected."
            return
        }

        $samsungOutput.Text = "Reading Samsung diagnostics. Please wait..."

        try {
            $result = Get-ACCLockDiagnostics -AdbPath $adbExecutable -Serial $serial

            if ($result.Manufacturer -notmatch "samsung") {
                $samsungOutput.Text = "Selected device is not identified as Samsung.`r`nManufacturer: $($result.Manufacturer)`r`nModel: $($result.Model)"
                return
            }

            $samsungOutput.Text = $result | Format-List | Out-String
        }
        catch {
            $samsungOutput.Text = "Diagnostics failed:`r`n$($_.Exception.Message)"
        }
    }.GetNewClosure())

    $universalPanel = New-ACCUniversalPanel -Parent $universalHost -Top 400
    $universalOutput = $universalPanel.Output

    $universalPanel.RunButton.Add_Click({
        $serial = [string]$deviceControl.SelectedItem

        if ([string]::IsNullOrWhiteSpace($serial)) {
            $universalOutput.Text = "No authorized Android device is selected."
            return
        }

        $universalOutput.Text = "Reading universal Android diagnostics. Please wait..."

        try {
            $result = Get-ACCLockDiagnostics -AdbPath $adbExecutable -Serial $serial
            $universalOutput.Text = $result | Format-List | Out-String
        }
        catch {
            $universalOutput.Text = "Diagnostics failed:`r`n$($_.Exception.Message)"
        }
    }.GetNewClosure())

    $recoveryPanel = New-ACCRecoveryPanel -Parent $recoveryHost

    return $tabs
}




