function New-ACCManufacturerTabs {
    param(
        [System.Windows.Forms.Control]$Parent
    )

    $tabs = New-Object System.Windows.Forms.TabControl
    $tabs.Name = "ACCManufacturerTabs"
    $tabs.Location = New-Object System.Drawing.Point(20,305)
    $tabs.Size = New-Object System.Drawing.Size(845,400)
    $tabs.Anchor = "Top,Bottom,Left,Right"
    $tabs.Font = New-Object System.Drawing.Font("Segoe UI",9)

    $brands = @(
        "Universal","Samsung","Recovery Center","Xiaomi","Tecno","Infinix",
        "OPPO","Vivo","Motorola","Google Pixel","Other Android"
    )

    foreach ($brand in $brands) {
        $page = New-Object System.Windows.Forms.TabPage
        $page.Text = $brand
        $page.Name = "ACC_" + ($brand -replace '[^A-Za-z0-9]', '')
        $page.BackColor = [System.Drawing.Color]::FromArgb(19,25,38)
        $page.ForeColor = [System.Drawing.Color]::White

        if ($brand -eq "Universal" -or $brand -eq "Samsung" -or $brand -eq "Recovery Center") {
            $hostPanel = New-Object System.Windows.Forms.Panel
            $hostPanel.Name = "ACC" + ($brand -replace '[^A-Za-z0-9]', '') + "Host"
            $hostPanel.Dock = "Fill"
            $hostPanel.AutoScroll = $true
            $hostPanel.BackColor = $page.BackColor
            $page.Controls.Add($hostPanel)
        }

        $tabs.TabPages.Add($page)
    }

    $Parent.Controls.Add($tabs)
    return $tabs
}

