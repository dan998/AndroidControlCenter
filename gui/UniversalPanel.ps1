function New-ACCUniversalPanel {
    param(
        [System.Windows.Forms.Control]$Parent,
        [int]$Top = 400
    )

    $heading = New-Object System.Windows.Forms.Label
    $heading.Text = "UNIVERSAL ANDROID DIAGNOSTICS"
    $heading.Location = New-Object System.Drawing.Point(20,$Top)
    $heading.Size = New-Object System.Drawing.Size(600,30)
    $heading.ForeColor = [System.Drawing.Color]::White
    $heading.Font = New-Object System.Drawing.Font("Segoe UI",14,[System.Drawing.FontStyle]::Bold)
    $Parent.Controls.Add($heading)

    $description = New-Object System.Windows.Forms.Label
    $description.Text = "Read-only diagnostics for authorized Android devices across supported manufacturers"
    $description.Location = New-Object System.Drawing.Point(20,($Top + 35))
    $description.Size = New-Object System.Drawing.Size(750,30)
    $description.ForeColor = [System.Drawing.Color]::Silver
    $Parent.Controls.Add($description)

    $runButton = New-Object System.Windows.Forms.Button
    $runButton.Name = "ACCUniversalRunDiagnostics"
    $runButton.Text = "Run diagnostics"
    $runButton.Location = New-Object System.Drawing.Point(20,($Top + 75))
    $runButton.Size = New-Object System.Drawing.Size(180,40)
    $runButton.BackColor = [System.Drawing.Color]::FromArgb(39,61,91)
    $runButton.ForeColor = [System.Drawing.Color]::White
    $runButton.FlatStyle = "Flat"
    $Parent.Controls.Add($runButton)

    $output = New-Object System.Windows.Forms.TextBox
    $output.Name = "ACCUniversalDiagnosticsOutput"
    $output.Location = New-Object System.Drawing.Point(20,($Top + 135))
    $output.Size = New-Object System.Drawing.Size(760,300)
    $output.Multiline = $true
    $output.ReadOnly = $true
    $output.ScrollBars = "Vertical"
    $output.BackColor = [System.Drawing.Color]::FromArgb(28,37,54)
    $output.ForeColor = [System.Drawing.Color]::White
    $output.Font = New-Object System.Drawing.Font("Consolas",10)
    $Parent.Controls.Add($output)

    $output.Text = "Select an authorized Android device and run diagnostics."

    return [PSCustomObject]@{
        RunButton = $runButton
        Output = $output
    }
}
