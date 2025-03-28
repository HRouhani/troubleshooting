# ============================
# Diagnostics Script
# 1. Open PowerShell with admin rights (Right-click > Run as Administrator)
# 2. This script gathers network connectivity information.
# 3. All output will be saved to a file named: Diagnostics.txt
# ============================


$logFile = "$PSScriptRoot\Diagnostics.txt"
Start-Transcript -Path $logFile -Append

Write-Host "`n=== Connectivity Diagnostic ===`n"

# bypassing execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# 1. System IP Address
Write-Host "1. Local IP Addresses:"
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.*" } | Format-Table -AutoSize

# 2. VPN Check
Write-Host "`n2. Network Interfaces (to infer VPN presence):"
Get-NetIPConfiguration | Format-Table InterfaceAlias, IPv4Address, DNSServer, InterfaceDescription -AutoSize

# 3. Proxy settings
Write-Host "`n3. System Proxy Configuration:"
netsh winhttp show proxy

# 4. DNS resolution
Write-Host "`n4. Resolving DNS for test-hx:"
Resolve-DnsName test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud

# 5. HTTP Connectivity Test (Port 80)
Write-Host "`n5. HTTP (port 80) Test with Invoke-WebRequest:"
try {
    $response = Invoke-WebRequest -Uri "http://test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud" -UseBasicParsing -TimeoutSec 10
    Write-Host "Status Code: $($response.StatusCode)"
} catch {
    Write-Warning "HTTP request failed: $_"
}

# 6. TCP Connectivity Test - Ports 80 & 443
Write-Host "`n6. TCP Port Test using Test-NetConnection:"
$ports = @(80, 443)
foreach ($port in $ports) {
    $result = Test-NetConnection -ComputerName test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud -Port $port
    Write-Host "`nPort ${port}:`n"
    $result | Format-List
}

Write-Host "`n=== End of Diagnostics ==="
Stop-Transcript
