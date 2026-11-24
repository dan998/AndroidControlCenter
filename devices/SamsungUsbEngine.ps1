# AndroidControlCenter - Samsung USB Detection Engine
# Read-only Windows Plug-and-Play detection.
# No flashing, resetting, unlocking, or device modifications.

Set-StrictMode -Version Latest

function Get-ACCSamsungUsbDevice {
    [CmdletBinding()]
    param()

    try {
        $devices = @(Get-PnpDevice -PresentOnly -ErrorAction Stop |
            Where-Object {
                $_.InstanceId -match '^USB\\VID_04E8&'
            })

        $results = foreach ($device in $devices) {
            $instanceId = $device.InstanceId
            $parent = $null
            $service = $null
            $hardwareIds = @()
            $compatibleIds = @()

            try {
                $properties = @(Get-PnpDeviceProperty `
                    -InstanceId $instanceId `
                    -KeyName @(
                        'DEVPKEY_Device_Parent',
                        'DEVPKEY_Device_Service',
                        'DEVPKEY_Device_HardwareIds',
                        'DEVPKEY_Device_CompatibleIds'
                    ) -ErrorAction Stop)

                foreach ($property in $properties) {
                    switch ($property.KeyName) {
                        'DEVPKEY_Device_Parent' {
                            $parent = [string]$property.Data
                        }
                        'DEVPKEY_Device_Service' {
                            $service = [string]$property.Data
                        }
                        'DEVPKEY_Device_HardwareIds' {
                            $hardwareIds = @($property.Data)
                        }
                        'DEVPKEY_Device_CompatibleIds' {
                            $compatibleIds = @($property.Data)
                        }
                    }
                }
            }
            catch {
                # Keep the device visible even if some properties are unavailable.
            }

            $interfaceType = 'Unknown Samsung USB interface'

            if ($instanceId -match '&ADB\\' -or
                $device.FriendlyName -match 'ADB Interface') {
                $interfaceType = 'ADB interface'
            }
            elseif ($device.FriendlyName -match 'Composite Device') {
                $interfaceType = 'Samsung composite device'
            }

            $parentDisplay = 'Not reported'

            if (-not [string]::IsNullOrWhiteSpace($parent)) {
                if ($parent -match '^USB\\VID_04E8&PID_([0-9A-F]{4})') {
                    $parentDisplay = "Samsung USB parent (PID $($Matches[1]))"
                }
                else {
                    $parentDisplay = 'Computer USB root hub or other host parent'
                }
            }

            $productId = 'Unknown'
            if ($instanceId -match 'VID_04E8&PID_([0-9A-F]{4})') {
                $productId = $Matches[1]
            }

            [PSCustomObject]@{
                Status        = [string]$device.Status
                Class         = [string]$device.Class
                Name          = [string]$device.FriendlyName
                VendorId      = '04E8'
                ProductId     = $productId
                InterfaceType = $interfaceType
                Service       = if ($service) { $service } else { 'Not reported' }
                Parent        = $parentDisplay
                HardwareIds   = @($hardwareIds)
                CompatibleIds = @($compatibleIds)
            }
        }

        if (@($results).Count -eq 0) {
            Write-Output 'No present Samsung USB devices were detected.'
        }
        else {
            $results
        }
    }
    catch {
        Write-Error "Samsung USB detection failed: $($_.Exception.Message)"
    }
}


