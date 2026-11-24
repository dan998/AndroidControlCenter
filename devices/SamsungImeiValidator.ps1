# AndroidControlCenter - IMEI Validator
# Format and Luhn checksum validation only.
# Does not retrieve or modify device identifiers.

Set-StrictMode -Version Latest

function Test-ACCImei {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Imei
    )

    $normalized = $Imei.Trim()

    if ($normalized -notmatch '^\d{15}$') {
        return [PSCustomObject]@{
            IsValid = $false
            Status = 'Invalid format'
            TAC = $null
            SerialNumber = $null
            CheckDigit = $null
        }
    }

    $sum = 0

    for ($i = 0; $i -lt 14; $i++) {
        $digit = [int]::Parse([string]$normalized[$i])

        if (($i % 2) -eq 1) {
            $digit *= 2
            if ($digit -gt 9) {
                $digit -= 9
            }
        }

        $sum += $digit
    }

    $expectedCheckDigit = (10 - ($sum % 10)) % 10
    $actualCheckDigit = [int]::Parse([string]$normalized[14])

    $isValid = ($expectedCheckDigit -eq $actualCheckDigit)

    [PSCustomObject]@{
        IsValid = $isValid
        Status = if ($isValid) { 'Valid checksum' } else { 'Invalid checksum' }
        TAC = $normalized.Substring(0, 8)
        SerialNumber = $normalized.Substring(8, 6)
        CheckDigit = [string]$actualCheckDigit
    }
}
