function New-ACCRecoveryPanel {
    param(
        [System.Windows.Forms.Control]$Parent
    )

    $heading = New-Object System.Windows.Forms.Label
    $heading.Text = "ANDROID RECOVERY CENTER"
    $heading.Location = New-Object System.Drawing.Point(20,15)
    $heading.Size = New-Object System.Drawing.Size(600,30)
    $heading.ForeColor = [System.Drawing.Color]::White
    $heading.Font = New-Object System.Drawing.Font("Segoe UI",14,[System.Drawing.FontStyle]::Bold)
    $Parent.Controls.Add($heading)

    $description = New-Object System.Windows.Forms.Label
    $description.Text = "Official account recovery, screen-lock guidance, FRP preparation and backup assistance"
    $description.Location = New-Object System.Drawing.Point(20,50)
    $description.Size = New-Object System.Drawing.Size(780,35)
    $description.ForeColor = [System.Drawing.Color]::Silver
    $Parent.Controls.Add($description)

    $output = New-Object System.Windows.Forms.TextBox
    $output.Name = "ACCRecoveryOutput"
    $output.Location = New-Object System.Drawing.Point(20,210)
    $output.Size = New-Object System.Drawing.Size(760,230)
    $output.Multiline = $true
    $output.ReadOnly = $true
    $output.ScrollBars = "Vertical"
    $output.BackColor = [System.Drawing.Color]::FromArgb(28,37,54)
    $output.ForeColor = [System.Drawing.Color]::White
    $output.Font = New-Object System.Drawing.Font("Consolas",10)
    $Parent.Controls.Add($output)

    $buttons = @(
        @{ Name="ACCRecoveryGoogle"; Text="Google Account Recovery"; X=20; Y=95 },
        @{ Name="ACCRecoveryScreenLock"; Text="Screen Lock Help"; X=215; Y=95 },
        @{ Name="ACCRecoveryFRP"; Text="FRP Readiness"; X=410; Y=95 },
        @{ Name="ACCRecoveryBackup"; Text="Backup & Restore"; X=605; Y=95 },
        @{ Name="ACCRecoveryOwnership"; Text="Ownership Help"; X=20; Y=150 }
    )

    $controls = @{}

    foreach ($item in $buttons) {
        $button = New-Object System.Windows.Forms.Button
        $button.Name = $item.Name
        $button.Text = $item.Text
        $button.Location = New-Object System.Drawing.Point($item.X,$item.Y)
        $button.Size = New-Object System.Drawing.Size(180,40)
        $button.BackColor = [System.Drawing.Color]::FromArgb(39,61,91)
        $button.ForeColor = [System.Drawing.Color]::White
        $button.FlatStyle = "Flat"
        $Parent.Controls.Add($button)
        $controls[$item.Name] = $button
    }

    $controls.ACCRecoveryGoogle.Add_Click({
        $output.Text = "GOOGLE ACCOUNT RECOVERY`r`n`r`nUse Google's official recovery process for a forgotten email address or password. Recovery may require a previously used device, recovery email or phone.`r`n`r`nThis application will never request or store your Google password.`r`n`r`nOpening the official Google recovery page..."
        try {
            Start-Process "https://accounts.google.com/signin/recovery"
        }
        catch {
            $output.AppendText("`r`nCould not open the browser: $($_.Exception.Message)")
        }
    }.GetNewClosure())

    $controls.ACCRecoveryScreenLock.Add_Click({
        $output.Text = "SCREEN LOCK RECOVERY`r`n`r`nAndroid does not provide a general method to reveal an existing forgotten PIN, password or pattern through ADB.`r`n`r`nCheck available backups and the manufacturer's official recovery guidance. A factory reset may erase local data and may trigger Factory Reset Protection (FRP).`r`n`r`nDo not attempt a reset until you understand the data-loss and account requirements."
    }.GetNewClosure())

    $controls.ACCRecoveryFRP.Add_Click({
        $output.Text = "FRP READINESS`r`n`r`nBefore an authorized reset, prepare:`r`n`r`n1. Access to the Google account previously synced with this phone.`r`n2. A working recovery email or phone where available.`r`n3. Stable internet access.`r`n4. Sufficient battery charge.`r`n5. A backup of important data, if accessible.`r`n6. Proof of ownership if authorized service is needed.`r`n`r`nThis is a preparation checklist, not a live FRP status detector. ADB lock diagnostics cannot prove that FRP is enabled or disabled."
    }.GetNewClosure())

    $controls.ACCRecoveryBackup.Add_Click({
        $output.Text = "BACKUP AND RESTORE`r`n`r`nBefore any factory reset, check:`r`n`r`n- Google backup and synchronization.`r`n- Photos, contacts and important documents.`r`n- WhatsApp or other application backups.`r`n- Manufacturer backup options, where supported.`r`n- Whether the backup can actually be accessed.`r`n`r`nA reset can permanently erase data that has not been backed up. Restore options depend on the device, account and available backups."
    }.GetNewClosure())

    $controls.ACCRecoveryOwnership.Add_Click({
        $output.Text = "OWNERSHIP AND AUTHORIZED SERVICE`r`n`r`nUse recovery procedures only for a device you own or are authorized to service.`r`n`r`nIf account recovery fails or FRP prevents setup, contact the manufacturer or an authorized service center. They may request valid proof of purchase and ownership.`r`n`r`nNever provide account passwords to this application or unofficial unlocking services."
    }.GetNewClosure())

    $output.Text = "Select a recovery option above.`r`n`r`nRecovery assistance does not bypass Android security or guarantee access to encrypted data."

    return [PSCustomObject]@{
        Output = $output
        Buttons = $controls
    }
}
