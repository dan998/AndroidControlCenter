function New-ACCSamsungPanel {
    param(
        [System.Windows.Forms.Control]$Parent
    )

    $heading = New-Object System.Windows.Forms.Label
    $heading.Text = "SAMSUNG DEVICE SERVICE"
    $heading.Location = New-Object System.Drawing.Point(20,15)
    $heading.Size = New-Object System.Drawing.Size(500,30)
    $heading.ForeColor = [System.Drawing.Color]::White
    $heading.Font = New-Object System.Drawing.Font("Segoe UI",14,[System.Drawing.FontStyle]::Bold)
    $Parent.Controls.Add($heading)

    $description = New-Object System.Windows.Forms.Label
    $description.Text = "Read-only device diagnostics and security information"
    $description.Location = New-Object System.Drawing.Point(20,50)
    $description.Size = New-Object System.Drawing.Size(600,25)
    $description.ForeColor = [System.Drawing.Color]::Silver
    $Parent.Controls.Add($description)

    $runButton = New-Object System.Windows.Forms.Button
    $runButton.Name = "ACCSamsungRunDiagnostics"
    $runButton.Text = "Run diagnostics"
    $runButton.Location = New-Object System.Drawing.Point(20,90)
    $runButton.Size = New-Object System.Drawing.Size(180,40)
    $runButton.BackColor = [System.Drawing.Color]::FromArgb(39,61,91)
    $runButton.ForeColor = [System.Drawing.Color]::White
    $runButton.FlatStyle = "Flat"
    $Parent.Controls.Add($runButton)

    $output = New-Object System.Windows.Forms.TextBox
    $output.Name = "ACCSamsungDiagnosticsOutput"
    $output.Location = New-Object System.Drawing.Point(20,150)
    $output.Size = New-Object System.Drawing.Size(760,300)
    $output.Multiline = $true
    $output.ReadOnly = $true
    $output.ScrollBars = "Vertical"
    $output.BackColor = [System.Drawing.Color]::FromArgb(28,37,54)
    $output.ForeColor = [System.Drawing.Color]::White
    $output.Font = New-Object System.Drawing.Font("Consolas",10)
    $Parent.Controls.Add($output)

    $output.Text = "Select an authorized Samsung device and run diagnostics."

    return [PSCustomObject]@{
        RunButton = $runButton
        Output = $output
    }
}
