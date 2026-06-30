<#
.SYNOPSIS
    Hot Reload — live-server (inyecta LiveReload en HTML)
    Compatible con PROJECT_MANAGER.ps1 (-Daemon, -Stop, -Status).
.DESCRIPTION
    Usa live-server.cmd con --livereload-port unico por proyecto.
    El proceso live-server corre totalmente desacoplado via .bat con < NUL
    y sobrevive independientemente del proceso que lo lanzó.
    
    TOKENS:  Guia JSP + MVC 8024 web 35730
#>
param([switch]$Stop, [switch]$Status, [switch]$Daemon)

$Label   = "Guia JSP + MVC"
$Port    = 8024
$LRPort  = 35730
$WebDir  = "web"
$SiteDir = if ($WebDir -ne "" -and (Test-Path "$PSScriptRoot\$WebDir")) { "$PSScriptRoot\$WebDir" } else { $PSScriptRoot }
$LogDir  = "$PSScriptRoot\logs"
$PidFile = "$LogDir\live-server.pid"
$BatFile = "$LogDir\run_liveserver.bat"
$LogFile = "$LogDir\live-server.log"
$ErrFile = "$LogDir\live-server_error.log"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

# ---------------------------------------------------------------------------
function Stop-LiveServer {
    # Mata por PIDs guardados
    if (Test-Path $PidFile) {
        (Get-Content $PidFile -Raw -EA SilentlyContinue) -split "`n" |
            Where-Object { $_ -match '^\d+$' } |
            ForEach-Object { Stop-Process -Id ([int]$_.Trim()) -Force -EA SilentlyContinue }
        Remove-Item $PidFile -Force -EA SilentlyContinue
    }
    # Safety net: mata por puertos
    @($Port, $LRPort) | ForEach-Object {
        Get-NetTCPConnection -LocalPort $_ -EA SilentlyContinue |
            Where-Object { $_.OwningProcess -gt 4 } |
            ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -EA SilentlyContinue }
    }
}

if ($Stop)   { Stop-LiveServer; Write-Host "$Label stopped" -ForegroundColor Green; return }
if ($Status) {
    $conn = Get-NetTCPConnection -LocalPort $Port -State Listen -EA SilentlyContinue
    Write-Host "$Label ($Port): $(if($conn){'ONLINE'}else{'OFFLINE'})" -ForegroundColor $(if($conn){'Green'}else{'Red'})
    return
}

# Limpia instancias previas
Stop-LiveServer
Start-Sleep -Milliseconds 500

Write-Host "=== $Label | SENA ADSO ===" -ForegroundColor Cyan
Write-Host "Serving $SiteDir on http://localhost:$Port" -ForegroundColor Green

# Determina ejecutable (global .cmd o fallback npx)
$lsExe = if (Test-Path "$env:APPDATA\npm\live-server.cmd") {
    "$env:APPDATA\npm\live-server.cmd"
} else {
    "npx.cmd"
}
$lsArgs = if ($lsExe -match "npx") {
    "live-server . --port=$Port --livereload-port=$LRPort --no-browser --quiet"
} else {
    ". --port=$Port --livereload-port=$LRPort --no-browser --quiet"
}

# Genera .bat — el < NUL desacopla live-server del árbol de procesos.
# El proceso node de live-server sobrevive indefinidamente una vez lanzado.
@"
@echo off
cd /d "$SiteDir"
"$lsExe" $lsArgs > "$LogFile" 2> "$ErrFile" < NUL
"@ | Out-File -FilePath $BatFile -Encoding ascii -Force

# Lanza cmd.exe que ejecuta el bat. cmd.exe termina en segundos;
# live-server (node) queda huérfano independiente — ESO ES LO DESEADO.
$proc = Start-Process -FilePath "cmd.exe" `
    -ArgumentList "/c `"$BatFile`"" `
    -WorkingDirectory $SiteDir `
    -WindowStyle Hidden `
    -PassThru

# Espera a que live-server establezca el puerto (max 8s)
$deadline = (Get-Date).AddSeconds(8)
while ((Get-Date) -lt $deadline) {
    Start-Sleep -Milliseconds 500
    $nodeConn = Get-NetTCPConnection -LocalPort $Port -State Listen -EA SilentlyContinue
    if ($nodeConn) { break }
}

$nodeConn = Get-NetTCPConnection -LocalPort $Port -State Listen -EA SilentlyContinue
$realNodePid = if ($nodeConn) { $nodeConn.OwningProcess } else { 0 }

# Guarda el PID del node (no del cmd.exe que ya terminó)
if ($realNodePid -gt 0) {
    "$realNodePid" | Out-File -FilePath $PidFile -Encoding UTF8 -Force
    Write-Host "✅ live-server PID:$realNodePid en :$Port (LR:$LRPort)" -ForegroundColor Green
} else {
    Write-Host "⚠️  live-server arrancando (no capturado aún)" -ForegroundColor Yellow
    Write-Host "   Log: $LogFile"
}

Write-Host "To stop: .\start-windows.ps1 -Stop" -ForegroundColor Yellow

# En modo -Daemon: el script termina inmediatamente.
# live-server ya corre desacoplado — no necesita watchdog.
# PROJECT_MANAGER puede usar -Status para verificar el puerto.

