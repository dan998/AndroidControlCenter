
# ==========================================================
# ANDROID CONTROL CENTER - WINDOWS 11
# ADB + SCRCPY + TERMUX
# USB / WIRELESS DEBUGGING
# ==========================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$ErrorActionPreference = "Continue"

# ---------------- CONFIGURATION ----------------

$script:adb = $null
$script:scrcpy = $null

function Find-Program($name, $localPath) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue

    if ($cmd) {
        return $cmd.Source
    }

    if (Test-Path $localPath) {
        return $localPath
    }

    return $null
}

$script:adb = Find-Program "adb" "$PSScriptRoot\platform-tools\adb.exe"
$script:scrcpy = Find-Program "scrcpy" "$PSScriptRoot\scrcpy.exe"

if (!$script:adb -or !$script:scrcpy) {
    [System.Windows.Forms.MessageBox]::Show(
        "ADB or scrcpy is missing.`n`nPlace scrcpy.exe beside this script and adb.exe inside platform-tools, or add both to PATH.",
        "Missing requirements"
    )
    exit
}

& $script:adb start-server | Out-Null

# ---------------- DEVICE FUNCTIONS ----------------

function Get-Devices {
    $output = & $script:adb devices 2>&1
    $devices = @()

    foreach ($line in $output) {
        if ($line -match "^(\S+)\s+device$") {
            $devices += $Matches[1]
        }
    }

    return $devices
}

function Get-SelectedDevice {
    if ($deviceList.SelectedItem) {
        return [string]$deviceList.SelectedItem
    }

    return $null
}

function Run-Adb($serial, $arguments) {
    if (!$serial) { return }

    $args = @("-s", $serial) + $arguments
    return & $script:adb @args 2>&1
}

function Show-Status($message) {
    $statusLabel.Text = $message
    $statusLabel.Refresh()
}

function Refresh-Devices {
    $previous = Get-SelectedDevice
    $deviceList.Items.Clear()

    $devices = @(Get-Devices)

    foreach ($device in $devices) {
        [void]$deviceList.Items.Add($device)
    }

    if ($devices.Count -gt 0) {
        if ($previous -and $devices -contains $previous) {
            $deviceList.SelectedItem = $previous
        }
        else {
            $deviceList.SelectedIndex = 0
        }

        Show-Status "$($devices.Count) authorized device(s) connected"
    }
    else {
        Show-Status "No authorized Android devices found."
    }

    Update-DeviceInfo
}

# ---------------- DEVICE INFORMATION ----------------

function Update-InfoPanel {
    $lines = @()

    if ($script:deviceInfoBase) {
        $lines += $script:deviceInfoBase
    }
    else {
        $lines += "No device selected."
    }

    $pairAddress = if ($pairAddressBox) { $pairAddressBox.Text.Trim() } else { "" }
    $pairCode = if ($pairCodeBox) { $pairCodeBox.Text.Trim() } else { "" }
    $connectAddress = if ($connectAddressBox) { $connectAddressBox.Text.Trim() } else { "" }

    $lines += ""
    $lines += "WIRELESS DEBUGGING"

    $lines += "Pairing IP:PORT: $(if ($pairAddress) { $pairAddress } else { '(not entered)' })"
    $lines += "Pairing Code: $(if ($pairCode) { $pairCode } else { '(not entered)' })"
    $lines += "Connection IP:PORT: $(if ($connectAddress) { $connectAddress } else { '(not entered)' })"

    $infoBox.Text = $lines -join [Environment]::NewLine
    $infoBox.SelectionStart = $infoBox.TextLength
    $infoBox.ScrollToCaret()
}

function Update-DeviceInfo {
    $serial = Get-SelectedDevice

    if (!$serial) {
        $script:deviceInfoBase = "No device selected."
        Update-InfoPanel
        return
    }

    $model = Run-Adb $serial @("shell", "getprop", "ro.product.model")
    $brand = Run-Adb $serial @("shell", "getprop", "ro.product.manufacturer")
    $android = Run-Adb $serial @("shell", "getprop", "ro.build.version.release")
    $battery = Run-Adb $serial @("shell", "dumpsys", "battery")

    $level = "Unknown"

    foreach ($line in $battery) {
        if ($line -match "level:\s*(\d+)") {
            $level = "$($Matches[1])%"
        }
    }

    $connection = if ($serial -match ":\d+$") {
        "Wireless"
    } else {
        "USB / ADB"
    }

    $script:deviceInfoBase = @"
Device ID: $serial
Manufacturer: $($brand -join "")
Model: $($model -join "")
Android version: $($android -join "")
Battery: $level
Connection: $connection
"@

    Update-InfoPanel
}

# ---------------- SCREEN MIRRORING ----------------

function Start-Mirroring {
    $serial = Get-SelectedDevice

    if (!$serial) {
        Show-Status "Select a device first."
        return
    }

    Show-Status "Launching full-screen mirroring..."

    Start-Process -FilePath $script:scrcpy `
        -ArgumentList @(
            "-s", $serial,
            "--fullscreen",
            "--stay-awake"
        )
}

# ---------------- TERMUX ----------------

function Open-Termux {
    $serial = Get-SelectedDevice

    if (!$serial) {
        Show-Status "Select a device first."
        return
    }

    $output = Run-Adb $serial @(
        "shell", "monkey", "-p", "com.termux", "1"
    )

    Show-Status "Launching Termux..."

    Start-Sleep -Milliseconds 1000

    Start-Mirroring
}

function Open-AdbShell {
    $serial = Get-SelectedDevice

    if (!$serial) {
        Show-Status "Select a device first."
        return
    }

    Start-Process -FilePath "cmd.exe" `
        -ArgumentList "/k `"$script:adb`" -s $serial shell"
}

function Execute-TermuxCommand {
    $serial = Get-SelectedDevice

    if (!$serial) {
        Show-Status "Select a device first."
        return
    }

    $command = [Microsoft.VisualBasic.Interaction]::InputBox(
        "Enter a Termux command. Requires Termux RUN_COMMAND permission and configuration.",
        "Termux command",
        "pwd"
    )

    if (!$command) { return }

    $output = Run-Adb $serial @(
        "shell",
        "am",
        "broadcast",
        "-n",
        "com.termux/com.termux.app.RunCommandService",
        "--es",
        "com.termux.RUN_COMMAND_PATH",
        "/data/data/com.termux/files/usr/bin/bash",
        "--esa",
        "com.termux.RUN_COMMAND_ARGUMENTS",
        "-lc,$command",
        "--ez",
        "com.termux.RUN_COMMAND_BACKGROUND",
        "false"
    )

    Show-Status "Termux command request sent. Check Termux for results."
}

# ---------------- WIRELESS DEBUGGING ----------------

function Pair-Wireless {
    $address = $pairAddressBox.Text.Trim()
    $code = $pairCodeBox.Text.Trim()

    if (!$address -or !$code) {
        Show-Status "Enter pairing IP:PORT and pairing code."
        return
    }

    $output = & $script:adb pair $address $code 2>&1

    if ($LASTEXITCODE -eq 0) {
        Show-Status "Pairing successful. Now enter connection IP:PORT."
    }
    else {
        Show-Status "Pairing failed: $($output -join ' ')"
    }
}

function Connect-Wireless {
    $address = $connectAddressBox.Text.Trim()

    if (!$address) {
        Show-Status "Enter connection IP:PORT."
        return
    }

    $output = & $script:adb connect $address 2>&1

    Refresh-Devices

    Show-Status ($output -join " ")
}

function Disconnect-Wireless {
    $serial = Get-SelectedDevice

    if (!$serial -or $serial -notmatch ":\d+$") {
        Show-Status "Select a wireless device first."
        return
    }

    & $script:adb disconnect $serial
    Refresh-Devices
}

# ---------------- SCREEN RECORDING ----------------

function Start-ScreenRecording {
    $serial = Get-SelectedDevice

    if (!$serial) {
        Show-Status "Select a device first."
        return
    }

    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.Filter = "MP4 Video|*.mp4"
    $dialog.FileName = "PhoneRecording.mp4"

    if ($dialog.ShowDialog() -ne "OK") {
        return
    }

    Start-Process -FilePath $script:scrcpy `
        -ArgumentList @(
            "-s", $serial,
            "--record=$($dialog.FileName)",
            "--fullscreen",
            "--stay-awake"
        )

    Show-Status "Screen recording launched."
}

# ---------------- FILE TRANSFER ----------------

function Transfer-File($direction) {
    $serial = Get-SelectedDevice

    if (!$serial) {
        Show-Status "Select a device first."
        return
    }

    if ($direction -eq "push") {
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Title = "Select file to send"

        if ($dialog.ShowDialog() -ne "OK") {
            return
        }

        $destination = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Android destination path",
            "Send file",
            "/sdcard/Download/"
        )

        if (!$destination) { return }

        $output = Run-Adb $serial @(
            "push", $dialog.FileName, $destination
        )
    }
    else {
        $source = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Enter Android source file path",
            "Download file",
            "/sdcard/Download/"
        )

        if (!$source) { return }

        $dialog = New-Object System.Windows.Forms.SaveFileDialog
        $dialog.FileName = [System.IO.Path]::GetFileName($source)

        if ($dialog.ShowDialog() -ne "OK") {
            return
        }

        $output = Run-Adb $serial @(
            "pull", $source, $dialog.FileName
        )
    }

    Show-Status ($output -join " ")
}

# ---------------- GUI HELPERS ----------------

$form = New-Object System.Windows.Forms.Form

$form.Text = "Android Control Center"
$form.Size = New-Object System.Drawing.Size(900, 820)
$form.MinimumSize = New-Object System.Drawing.Size(900, 820)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(19,25,38)
$form.ForeColor = [System.Drawing.Color]::White

function Add-Label($text, $x, $y, $width = 220) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $text
    $label.Location = New-Object System.Drawing.Point($x,$y)
    $label.Size = New-Object System.Drawing.Size($width,25)
    $label.ForeColor = [System.Drawing.Color]::White
    $form.Controls.Add($label)
    return $label
}

function Add-Button($text, $x, $y, $width, $height, $action) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Location = New-Object System.Drawing.Point($x,$y)
    $button.Size = New-Object System.Drawing.Size($width,$height)
    $button.FlatStyle = "Flat"
    $button.BackColor = [System.Drawing.Color]::FromArgb(39,61,91)
    $button.ForeColor = [System.Drawing.Color]::White
    $button.Add_Click($action)
    $form.Controls.Add($button)
    return $button
}

function Add-Input($x,$y,$width = 250) {
    $box = New-Object System.Windows.Forms.TextBox
    $box.Location = New-Object System.Drawing.Point($x,$y)
    $box.Size = New-Object System.Drawing.Size($width,27)
    $box.BackColor = [System.Drawing.Color]::White
    $box.ForeColor = [System.Drawing.Color]::Black
    $box.Font = New-Object System.Drawing.Font("Segoe UI",10)
    $box.UseSystemPasswordChar = $false
    $box.PasswordChar = [char]0
    $box.Enabled = $true
    $box.ReadOnly = $false
    $box.Multiline = $false
    $box.TabStop = $true
    $box.Visible = $true
    $form.Controls.Add($box)
    return $box
}

# ---------------- DASHBOARD HEADER ----------------

$title = Add-Label "ANDROID CONTROL CENTER" 25 18 700
$title.Font = New-Object System.Drawing.Font(
    "Segoe UI",19,[System.Drawing.FontStyle]::Bold
)

Add-Label "CONNECTED DEVICE" 30 65 250

$deviceList = New-Object System.Windows.Forms.ComboBox
$deviceList.Location = New-Object System.Drawing.Point(30,95)
$deviceList.Size = New-Object System.Drawing.Size(400,30)
$deviceList.DropDownStyle = "DropDownList"
$form.Controls.Add($deviceList)

$deviceList.Add_SelectedIndexChanged({
    Update-DeviceInfo
})

Add-Button "Refresh" 450 93 140 32 {
    Refresh-Devices
}

# ---------------- INFORMATION PANEL ----------------

$infoBox = New-Object System.Windows.Forms.TextBox
$infoBox.Location = New-Object System.Drawing.Point(30,140)
$infoBox.Size = New-Object System.Drawing.Size(560,150)
$infoBox.Multiline = $true
$infoBox.ScrollBars = "Vertical"
$infoBox.ReadOnly = $true
$infoBox.BackColor = [System.Drawing.Color]::FromArgb(28,37,54)
$infoBox.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($infoBox)

# ---------------- PHONE CONTROLS ----------------

Add-Label "PHONE CONTROL" 30 305 250

Add-Button "Full-screen mirroring" 30 335 260 45 {
    Start-Mirroring
}

Add-Button "Open Termux" 310 335 260 45 {
    Open-Termux
}

Add-Button "ADB terminal" 30 390 260 45 {
    Open-AdbShell
}

Add-Button "Run Termux command" 310 390 260 45 {
    Execute-TermuxCommand
}

Add-Button "Screen recording" 590 335 260 45 {
    Start-ScreenRecording
}

Add-Button "Device information" 590 390 260 45 {
    Update-DeviceInfo
    Show-Status "Information refreshed."
}

# ---------------- FILE MANAGEMENT ----------------

Add-Label "FILE MANAGEMENT" 30 455

Add-Button "Send file to phone" 30 485 260 40 {
    Transfer-File "push"
}

Add-Button "Download from phone" 310 485 260 40 {
    Transfer-File "pull"
}

# ---------------- WIRELESS SECTION ----------------

Add-Label "WIRELESS DEBUGGING" 30 550 250

Add-Label "Pairing IP:PORT" 30 585
$pairAddressBox = Add-Input 180 583 240

Add-Label "Pairing code" 30 620
$pairCodeBox = Add-Input 180 618 240

Add-Button "Pair device" 450 582 140 32 {
    Pair-Wireless
}

Add-Label "Connection IP:PORT" 30 655
$connectAddressBox = Add-Input 180 653 240

$pairAddressBox.Add_TextChanged({ Update-InfoPanel })
$pairCodeBox.Add_TextChanged({ Update-InfoPanel })
$connectAddressBox.Add_TextChanged({ Update-InfoPanel })

Update-InfoPanel

Add-Button "Connect Wi-Fi" 450 652 140 32 {
    Connect-Wireless
}

Add-Button "Disconnect Wi-Fi" 610 582 180 40 {
    Disconnect-Wireless
}

# ---------------- STATUS ----------------

$statusLabel = Add-Label "Ready" 30 715 800
$statusLabel.ForeColor = [System.Drawing.Color]::LightGreen

. "$PSScriptRoot\gui\ManufacturerIntegration.ps1"
$script:manufacturerTabs = Add-ACCManufacturerIntegration -Form $form -DeviceSelector $deviceList -AdbPath $script:adb

# ---------------- SAFE AUTO REFRESH ----------------

$script:refreshInProgress = $false
$script:appClosing = $false

$script:timer = New-Object System.Windows.Forms.Timer
$script:timer.Interval = 5000

$script:timer.Add_Tick({

    if ($script:appClosing -or $script:refreshInProgress) {
        return
    }

    $script:refreshInProgress = $true

    try {
        $devices = @(Get-Devices)
        $changed = $false

        if ($devices.Count -ne $deviceList.Items.Count) {
            $changed = $true
        }
        else {
            foreach ($device in $devices) {
                if (!$deviceList.Items.Contains($device)) {
                    $changed = $true
                    break
                }
            }
        }

        if ($changed -and !$script:appClosing) {
            Refresh-Devices
        }
    }
    catch {
        if (!$script:appClosing) {
            try {
                Show-Status ("Automatic refresh error: " + $_.Exception.Message)
            }
            catch {
                # Do not allow a status-display error to crash the timer.
            }
        }
    }
    finally {
        $script:refreshInProgress = $false
    }
})

$form.Add_Shown({
    if ($script:appClosing) {
        return
    }

    try {
        Refresh-Devices
    }
    catch {
        Show-Status ("Initial device refresh error: " + $_.Exception.Message)
    }

    if (!$script:appClosing) {
        $script:timer.Start()
    }
})

$form.Add_FormClosing({
    $script:appClosing = $true
    $script:timer.Stop()
})

$form.Add_FormClosed({
    $script:appClosing = $true
    $script:timer.Stop()
    $script:timer.Dispose()
})

[void]$form.ShowDialog()

