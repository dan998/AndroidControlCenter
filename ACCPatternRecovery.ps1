Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
$script:AdbPath = if ($adbCommand) { $adbCommand.Source } else { $null }

$form = New-Object System.Windows.Forms.Form
$form.Text = "AndroidControlCenter - Pattern Recovery"
$form.Size = New-Object System.Drawing.Size(760, 650)
$form.MinimumSize = New-Object System.Drawing.Size(760, 650)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(19,25,38)
$form.ForeColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$title = New-Object System.Windows.Forms.Label
$title.Text = "ANDROID PATTERN RECOVERY CENTER"
$title.Location = New-Object System.Drawing.Point(20,15)
$title.Size = New-Object System.Drawing.Size(700,35)
$title.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($title)

$description = New-Object System.Windows.Forms.Label
$description.Text = "Read-only diagnostics and official recovery assistance"
$description.Location = New-Object System.Drawing.Point(22,52)
$description.Size = New-Object System.Drawing.Size(700,25)
$description.ForeColor = [System.Drawing.Color]::LightGray
$form.Controls.Add($description)

$deviceLabel = New-Object System.Windows.Forms.Label
$deviceLabel.Text = "CONNECTED ANDROID DEVICE"
$deviceLabel.Location = New-Object System.Drawing.Point(22,95)
$deviceLabel.Size = New-Object System.Drawing.Size(400,25)
$deviceLabel.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($deviceLabel)

$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(22,125)
$outputBox.Size = New-Object System.Drawing.Size(700,190)
$outputBox.Multiline = $true
$outputBox.ReadOnly = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.BackColor = [System.Drawing.Color]::FromArgb(30,38,52)
$outputBox.ForeColor = [System.Drawing.Color]::White
$outputBox.Font = New-Object System.Drawing.Font("Consolas",10)
$form.Controls.Add($outputBox)

$refreshButton = New-Object System.Windows.Forms.Button
$refreshButton.Text = "Refresh Device"
$refreshButton.Location = New-Object System.Drawing.Point(22,330)
$refreshButton.Size = New-Object System.Drawing.Size(150,38)
$form.Controls.Add($refreshButton)

$googleButton = New-Object System.Windows.Forms.Button
$googleButton.Text = "Google Account Recovery"
$googleButton.Location = New-Object System.Drawing.Point(190,330)
$googleButton.Size = New-Object System.Drawing.Size(220,38)
$form.Controls.Add($googleButton)

$samsungButton = New-Object System.Windows.Forms.Button
$samsungButton.Text = "Samsung Recovery Help"
$samsungButton.Location = New-Object System.Drawing.Point(428,330)
$samsungButton.Size = New-Object System.Drawing.Size(220,38)
$form.Controls.Add($samsungButton)

$infoBox = New-Object System.Windows.Forms.TextBox
$infoBox.Location = New-Object System.Drawing.Point(22,390)
$infoBox.Size = New-Object System.Drawing.Size(700,155)
$infoBox.Multiline = $true
$infoBox.ReadOnly = $true
$infoBox.ScrollBars = "Vertical"
$infoBox.BackColor = [System.Drawing.Color]::FromArgb(30,38,52)
$infoBox.ForeColor = [System.Drawing.Color]::White
$infoBox.Font = New-Object System.Drawing.Font("Segoe UI",10)
$infoBox.Text = @"
PATTERN RECOVERY INFORMATION

1. There is no universal method to reveal or bypass a forgotten Android pattern.
2. Some eligible Samsung devices running One UI 6.1 or later may offer recovery
   using the previous screen-lock credential within 72 hours of changing it.
   Eligibility and the on-screen recovery process must be verified for the device.
3. Recover the associated Google account before considering a factory reset.
4. A factory reset erases local data and may trigger Factory Reset Protection.
5. ADB cannot reveal the existing screen-lock pattern.

This utility does not attempt pattern guessing, credential extraction,
lock removal, FRP bypass or factory reset.
"@
$form.Controls.Add($infoBox)

$footer = New-Object System.Windows.Forms.Label
$footer.Text = "Independent test utility - no changes to the main application"
$footer.Location = New-Object System.Drawing.Point(22,565)
$footer.Size = New-Object System.Drawing.Size(700,25)
$footer.ForeColor = [System.Drawing.Color]::LightGray
$form.Controls.Add($footer)

function Update-ACCDeviceStatus {
    if (-not $script:AdbPath) {
        $outputBox.Text = "ADB was not found. Install or configure Android Platform Tools."
        return
    }

    try {
        $lines = @(& $script:AdbPath devices -l 2>&1)
        $devices = @(
            $lines | Where-Object {
                $_ -match '^\s*\S+\s+(device|unauthorized|offline)\b'
            }
        )

        if ($devices.Count -eq 0) {
            $outputBox.Text = "No Android device detected.`r`n`r`nConnect a device and refresh."
            return
        }

        $report = @()

        foreach ($line in $devices) {
            if ($line -match '^\s*(\S+)\s+(device|unauthorized|offline)\b(.*)$') {
                $serial = $Matches[1]
                $status = $Matches[2]
                $details = $Matches[3]

                $report += "Connection ID: $serial"
                $report += "ADB status: $status"

                if ($status -eq "device") {
                    $manufacturer = (& $script:AdbPath -s $serial shell getprop ro.product.manufacturer 2>$null | Out-String).Trim()
                    $model = (& $script:AdbPath -s $serial shell getprop ro.product.model 2>$null | Out-String).Trim()
                    $android = (& $script:AdbPath -s $serial shell getprop ro.build.version.release 2>$null | Out-String).Trim()

                    $report += "Manufacturer: $manufacturer"
                    $report += "Model: $model"
                    $report += "Android version: $android"
                    $report += "Authorization: Granted"
                }
                elseif ($status -eq "unauthorized") {
                    $report += "Authorization: Not granted"
                    $report += "Unlock the phone and approve the USB debugging prompt if available."
                }
                else {
                    $report += "The device is offline."
                }

                $report += " "
            }
        }

        $outputBox.Text = $report -join "`r`n"
    }
    catch {
        $outputBox.Text = "Device detection failed:`r`n$($_.Exception.Message)"
    }
}

$refreshButton.Add_Click({
    Update-ACCDeviceStatus
})

$googleButton.Add_Click({
    Start-Process "https://accounts.google.com/signin/recovery"
})

$samsungButton.Add_Click({
    Start-Process "https://www.samsung.com/us/support/troubleshoot/TSG10001451/"
})

$form.Add_Shown({
    Update-ACCDeviceStatus
})

[void]$form.ShowDialog()
