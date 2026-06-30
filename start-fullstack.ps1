<#
.SYNOPSIS
    Full Stack Startup - Native Windows (without Docker)
    Starts PostgreSQL + FastAPI + React natively on Windows.
    
    Parallel mode to docker-compose: same architecture, no containers.
.DESCRIPTION
    Use this script when you want to run everything natively on Windows
    without Docker. Requires:
      - PostgreSQL 16 installed as Windows service
      - Python 3.10+ with venv
      - Node.js 18+
    
    Run from PowerShell as Administrator (for PostgreSQL service control).
.PARAMETER Stop
    Stop all services.
.PARAMETER Status
    Show status of all services.
#>

param([switch]$Stop, [switch]$Status)

$ProjectRoot = "$PSScriptRoot"
$PythonVenv  = "$ProjectRoot\recursos\fastapi-inventario\venv"
$FastApiDir  = "$ProjectRoot\recursos\fastapi-inventario"
$ReactDir    = "$ProjectRoot\recursos\frontend-inventario"
$LogDir      = "$ProjectRoot\logs"
$FastApiPort = 8000
$ReactPort   = 5173

# Ensure log directory exists
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

# =========================================================================
# Utility functions
# =========================================================================

function Write-Banner {
    param([string]$Text, [string]$Color = "Cyan")
    Write-Host "`n========================================" -ForegroundColor $Color
    Write-Host "  $Text" -ForegroundColor $Color
    Write-Host "========================================" -ForegroundColor $Color
}

function Get-PidOnPort {
    param([int]$Port)
    try {
        $conn = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        if ($conn) { return $conn.OwningProcess } else { return $null }
    } catch { return $null }
}

function Get-ProcessName {
    param([int]$Pid)
    try { return (Get-Process -Id $Pid -ErrorAction SilentlyContinue).ProcessName } catch { return "N/A" }
}

# =========================================================================
# PORT/STATUS TABLE
# =========================================================================
$services = @(
    @{ Name = "PostgreSQL";     Port = 5432; Type = "database" }
    @{ Name = "FastAPI Backend"; Port = $FastApiPort; Type = "backend" }
    @{ Name = "React Frontend";  Port = $ReactPort; Type = "frontend" }
)

# =========================================================================
# STOP
# =========================================================================
if ($Stop) {
    Write-Banner "STOPPING ALL SERVICES" "Red"

    # Stop React (Vite / Node)
    $reactPid = Get-PidOnPort $ReactPort
    if ($reactPid) { Stop-Process -Id $reactPid -Force -ErrorAction SilentlyContinue; Write-Host "  ⏹ React (PID $reactPid) stopped" -ForegroundColor Yellow }

    # Stop FastAPI (Uvicorn)
    $fastPid = Get-PidOnPort $FastApiPort
    if ($fastPid) { Stop-Process -Id $fastPid -Force -ErrorAction SilentlyContinue; Write-Host "  ⏹ FastAPI (PID $fastPid) stopped" -ForegroundColor Yellow }

    # Stop Python venv processes
    Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match "uvicorn" } | Stop-Process -Force

    Write-Host "`n✅ All services stopped" -ForegroundColor Green
    return
}

# =========================================================================
# STATUS
# =========================================================================
if ($Status) {
    Write-Banner "SERVICE STATUS" "Cyan"
    foreach ($svc in $services) {
        $pid = Get-PidOnPort $svc.Port
        $procName = if ($pid) { Get-ProcessName $pid } else { "—" }
        $status = if ($pid) { "ONLINE" } else { "OFFLINE" }
        $color = if ($pid) { "Green" } else { "Red" }
        Write-Host "  $($svc.Name.PadRight(20)) port $($svc.Port.ToString().PadRight(6)) [$status]" -ForegroundColor $color
    }
    return
}

# =========================================================================
# START
# =========================================================================
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   FULL STACK STARTUP - NATIVE WINDOWS           ║" -ForegroundColor Cyan
Write-Host "║   Parallel to: docker compose up                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n📋 Architecture:" -ForegroundColor Yellow
Write-Host "   Native         Docker Equivalent"
Write-Host "   ──────────     ────────────────"
Write-Host "   PostgreSQL     → db container (:5432)"
Write-Host "   FastAPI/uvicorn  → api container (:8000)"
Write-Host "   Vite/React     → frontend container (:5173)"
Write-Host ""

# -------------------------------------------------------------------------
# 1. PostgreSQL (Windows Service)
# -------------------------------------------------------------------------
Write-Banner "1/3: PostgreSQL (native Windows service)" "Green"
$pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue
if (-not $pgService) {
    Write-Host "  ⚠ PostgreSQL service not found." -ForegroundColor Yellow
    Write-Host "  → Start manually or install from https://www.postgresql.org/download/" -ForegroundColor Yellow
} else {
    if ($pgService.Status -ne "Running") {
        Write-Host "  Starting PostgreSQL service..." -ForegroundColor Gray
        Start-Service -Name $pgService.Name
        Start-Sleep -Seconds 3
    }
    $pgService.Refresh()
    if ($pgService.Status -eq "Running") {
        Write-Host "  ✅ PostgreSQL is RUNNING (port 5432)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Failed to start PostgreSQL" -ForegroundColor Red
    }
}

# -------------------------------------------------------------------------
# 2. FastAPI
# -------------------------------------------------------------------------
Write-Banner "2/3: FastAPI Backend (uvicorn)" "Green"

# Verify Python venv exists, create if needed
if (-not (Test-Path "$PythonVenv\Scripts\python.exe")) {
    Write-Host "  Creating Python virtual environment..." -ForegroundColor Yellow
    python -m venv $PythonVenv
}

# Install/verify dependencies
& "$PythonVenv\Scripts\pip.exe" install -q -r "$FastApiDir\requirements.txt" 2>$null
Write-Host "  ✅ Dependencies installed" -ForegroundColor Green

# Kill existing process on port
$existingPid = Get-PidOnPort $FastApiPort
if ($existingPid) { Stop-Process -Id $existingPid -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 }

# Start FastAPI
$fastApiLog = "$LogDir\fastapi.log"
$fastApiArgs = @("-m", "uvicorn", "main:app", "--reload", "--host", "0.0.0.0", "--port", "$FastApiPort")
$fastProc = Start-Process -FilePath "$PythonVenv\Scripts\python.exe" -ArgumentList $fastApiArgs -WorkingDirectory $FastApiDir -WindowStyle Hidden -RedirectStandardOutput $fastApiLog -RedirectStandardError $fastApiLog -PassThru

Start-Sleep -Seconds 3
$fastPidCheck = Get-PidOnPort $FastApiPort
if ($fastPidCheck) {
    Write-Host "  ✅ FastAPI running on http://localhost:$FastApiPort" -ForegroundColor Green
    Write-Host "  📘 Swagger docs: http://localhost:$FastApiPort/docs" -ForegroundColor Cyan
    Write-Host "  📗 ReDoc:        http://localhost:$FastApiPort/redoc" -ForegroundColor Cyan
} else {
    Write-Host "  ❌ FastAPI failed to start. Check logs: $fastApiLog" -ForegroundColor Red
}

# -------------------------------------------------------------------------
# 3. React Frontend
# -------------------------------------------------------------------------
Write-Banner "3/3: React Frontend (Vite)" "Green"

# Verify Node.js is available
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Write-Host "  ❌ Node.js not found. Install from https://nodejs.org/" -ForegroundColor Red
} else {
    # Install npm dependencies if needed
    if (-not (Test-Path "$ReactDir\node_modules\.package-lock.json")) {
        Write-Host "  Installing npm dependencies..." -ForegroundColor Yellow
        & "npm" install --prefix "$ReactDir" 2>$null
    }

    # Kill existing process on port
    $existingReact = Get-PidOnPort $ReactPort
    if ($existingReact) { Stop-Process -Id $existingReact -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 }

    # Start Vite
    $reactLog = "$LogDir\react.log"
    $reactProc = Start-Process -FilePath "npx.cmd" -ArgumentList "vite", "--port", "$ReactPort" -WorkingDirectory $ReactDir -WindowStyle Hidden -RedirectStandardOutput $reactLog -RedirectStandardError $reactLog -PassThru

    Start-Sleep -Seconds 4
    $reactPidCheck = Get-PidOnPort $ReactPort
    if ($reactPidCheck) {
        Write-Host "  ✅ React running on http://localhost:$ReactPort" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ React may still be starting. Check logs: $reactLog" -ForegroundColor Yellow
        Write-Host "  → Try: cd recursos\frontend-inventario && npm run dev" -ForegroundColor Yellow
    }
}

# -------------------------------------------------------------------------
# Summary
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              STATUS SUMMARY                      ║" -ForegroundColor Cyan
Write-Host "╠══════════════════════════════════════════════════╣" -ForegroundColor Cyan

foreach ($svc in $services) {
    $pid = Get-PidOnPort $svc.Port
    $statusIcon = if ($pid) { "✅" } else { "⏳" }
    $statusText = if ($pid) { "ONLINE" } else { "OFFLINE" }
    $url = switch ($svc.Type) {
        "database" { "postgresql://localhost:5432/inventario_db" }
        "backend"  { "http://localhost:$($svc.Port)/docs" }
        "frontend" { "http://localhost:$($svc.Port)" }
    }
    Write-Host "  $statusIcon $($svc.Name.PadRight(20)) $statusText" -ForegroundColor $(if ($pid) { "Green" } else { "Yellow" })
    Write-Host "            $url" -ForegroundColor $(if ($pid) { "Cyan" } else { "Gray" })
}

Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n📝 Commands:" -ForegroundColor Yellow
Write-Host "  .\start-fullstack.ps1          Start all services" -ForegroundColor White
Write-Host "  .\start-fullstack.ps1 -Stop    Stop all services" -ForegroundColor White
Write-Host "  .\start-fullstack.ps1 -Status  Check status" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Open in browser: http://localhost:$ReactPort" -ForegroundColor Green
