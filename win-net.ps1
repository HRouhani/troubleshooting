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
# CMD Equivalent:
# netsh winhttp show proxy

# 4. DNS resolution
Write-Host "`n4. Resolving DNS for test-hx:"
Resolve-DnsName test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud
# CMD Equivalent:
# nslookup test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud

# 5. HTTP Connectivity Test (Port 80)
Write-Host "`n5. HTTP (port 80) Test with Invoke-WebRequest:"
try {
    $response = Invoke-WebRequest -Uri "http://test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud" -UseBasicParsing -TimeoutSec 10
    Write-Host "Status Code: $($response.StatusCode)"
} catch {
    Write-Warning "HTTP request failed: $_"
}
# CMD Equivalent:
# curl http://test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud

# 6. TCP Connectivity Test - Ports 80 & 443
Write-Host "`n6. TCP Port Test using Test-NetConnection:"
$ports = @(80, 443)
foreach ($port in $ports) {
    $result = Test-NetConnection -ComputerName test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud -Port $port
    Write-Host "`nPort ${port}:`n"
    $result | Format-List
}
# CMD Equivalent:
# telnet only tests TCP connectivity, not the TLS handshake (443)
# telnet test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud 80
# or: (-k ignore certificate errors)
# curl -v telnet://test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud:80
# curl -vk https://test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud:443

# 7. Traceroute to diagnose where the traffic might be blocked
Write-Host "`n7. Traceroute to detect path issues:"
tracert test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud
# CMD Equivalent:
# tracert test-hx.cdcfireeyehxusdev.aws.platform.porsche-preview.cloud


Write-Host "`n=== End of Diagnostics ==="
Stop-Transcript
