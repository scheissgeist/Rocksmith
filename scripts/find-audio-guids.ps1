# PowerShell script to find audio device GUIDs
# Run this to discover your speaker and USB guitar cable GUIDs

Write-Host "======================================"
Write-Host "  Rocksmith Audio Device GUID Finder"
Write-Host "======================================"
Write-Host ""

Write-Host "OUTPUT DEVICES (Speakers/Headphones):"
Write-Host "-------------------------------------"

$renderDevices = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render"
foreach ($device in $renderDevices) {
    $guid = $device.PSChildName
    $propsPath = "$($device.PSPath)\Properties"
    if (Test-Path $propsPath) {
        $props = Get-ItemProperty $propsPath -ErrorAction SilentlyContinue
        $name = $props."{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
        if ($name) {
            Write-Host "$guid : $name"
        }
    }
}

Write-Host ""
Write-Host "INPUT DEVICES (USB Guitar Cable):"
Write-Host "-------------------------------------"

$captureDevices = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture"
foreach ($device in $captureDevices) {
    $guid = $device.PSChildName
    $propsPath = "$($device.PSPath)\Properties"
    if (Test-Path $propsPath) {
        $props = Get-ItemProperty $propsPath -ErrorAction SilentlyContinue
        $name = $props."{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
        if ($name) {
            Write-Host "$guid : $name"
        }
    }
}

Write-Host ""
Write-Host "======================================"
Write-Host "Copy the GUID for:"
Write-Host "  1. Your OUTPUT device (speakers/headphones)"
Write-Host "  2. Your INPUT device (USB guitar cable)"
Write-Host ""
Write-Host "You'll need these for FL Studio ASIO configuration"
Write-Host "======================================"
Write-Host ""
Pause
