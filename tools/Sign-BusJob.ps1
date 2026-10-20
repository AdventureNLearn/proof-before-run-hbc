# Reference signer for v3 jobs (proof-before-run).
# Covers the full block including the caps section.
# Fail-closed: exits 3 on bad key, missing sig, or mismatch.
# Key is expected under DPAPI / user-account protection (same model as HiveBrainComms).

param(
    [Parameter(Mandatory=$true)][string]$JobFile,
    [ValidateSet('Sign','Verify')][string]$Mode = 'Verify',
    [string]$KeyPath = "$env:LOCALAPPDATA\HiveBrainComms\bus-key.bin"
)

function Get-CanonicalBlock {
    param([string]$Path)
    $lines = Get-Content -LiteralPath $Path -Encoding UTF8
    $block = @()
    foreach ($line in $lines) {
        if ($line -match '^sig:\s*') { break }
        $block += $line
    }
    return ($block -join "`n")
}

if (-not (Test-Path $KeyPath)) {
    Write-Error "Signing key missing. Exit 3."
    exit 3
}

$key = [System.IO.File]::ReadAllBytes($KeyPath)
$hmac = New-Object System.Security.Cryptography.HMACSHA256
$hmac.Key = $key

$canonical = Get-CanonicalBlock -Path $JobFile
$bytes = [System.Text.Encoding]::UTF8.GetBytes($canonical)
$hash = $hmac.ComputeHash($bytes)
$computed = [BitConverter]::ToString($hash).Replace('-','').ToLower()

if ($Mode -eq 'Sign') {
    # Append or replace sig line
    $content = Get-Content -LiteralPath $JobFile -Raw
    if ($content -match '(?m)^sig:\s*.*$') {
        $content = $content -replace '(?m)^sig:\s*.*$', "sig: $computed"
    } else {
        $content += "`nsig: $computed`n"
    }
    Set-Content -LiteralPath $JobFile -Value $content -Encoding UTF8 -NoNewline
    Write-Output "Signed: $computed"
    exit 0
}

# Verify
$existing = (Select-String -Path $JobFile -Pattern '^sig:\s*(.+)$').Matches.Groups[1].Value.Trim()
if (-not $existing -or $existing -ne $computed) {
    Write-Error "Signature mismatch or missing. Exit 3."
    exit 3
}
Write-Output "Verified."
exit 0
