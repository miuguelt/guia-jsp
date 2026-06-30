<#
.SYNOPSIS
    DevBrain Session Start Protocol (Windows PowerShell)
    Protocolo de inicio de sesion de agente DevBrain.
    Proyecto: Guia JSP + MVC | SENA ADSO
#>
param(
    [switch]$SkipIntegrity,
    [switch]$Fast
)

$ErrorActionPreference = "Continue"
$ProjectRoot = $PSScriptRoot | Split-Path -Parent
Set-Location $ProjectRoot

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  DevBrain Session Start Protocol" -ForegroundColor Cyan
Write-Host "  Guia JSP + MVC | SENA ADSO" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Verificar directorio prohibido
$CWD = Get-Location
if ($CWD.Path -match "VALIDATED|backup|archive|tmp|duplicate") {
    Write-Host "FATAL: Estás en un directorio prohibido: $CWD" -ForegroundColor Red
    Write-Host "   Debes estar en: guia-jsp/" -ForegroundColor Red
    exit 1
}

# 2. Verificar repo git
if (-not (Test-Path ".git")) {
    Write-Host "Inicializando repositorio Git..." -ForegroundColor Yellow
    git init
    git add -A
    git commit -m "chore: inicializacion del repositorio" --allow-empty
}

# 3. Guardar estado actual
Write-Host "`n[1/4] Guardando checkpoint inicial..." -ForegroundColor Yellow
git add -A 2>$null
$timestamp = Get-Date -Format "yyyy-MM-dd_HH:mm:ss"
git commit -m "checkpoint: inicio de sesion $timestamp" --allow-empty 2>$null | Out-Null
$tag = "session-start-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
git tag $tag 2>$null | Out-Null
Write-Host "   Tag creado: $tag" -ForegroundColor Green

# 4. Verificar integridad
if (-not $SkipIntegrity) {
    Write-Host "`n[2/4] Verificando integridad..." -ForegroundColor Yellow
    $intArgs = @()
    if ($Fast) { $intArgs += "-Fast" }
    if (Test-Path "$PSScriptRoot\integrity-check.ps1") {
        & "$PSScriptRoot\integrity-check.ps1" @intArgs
    } else {
        Write-Host "   Skip (no hay integrity-check.ps1)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "`n[2/4] Skip integrity check" -ForegroundColor DarkGray
}

# 5. Mostrar archivos criticos
Write-Host "`n[3/4] Archivos criticos activos:" -ForegroundColor Yellow
$criticalFiles = @(
    "web\index.html",
    "web\css\styles.css",
    "web\js\main.js",
    "recursos\sql\inventario_db.sql",
    "recursos\docker\Dockerfile"
)
foreach ($f in $criticalFiles) {
    $full = Join-Path $ProjectRoot $f
    if (Test-Path $full) {
        Write-Host "   [OK] $f" -ForegroundColor DarkGreen
    } else {
        Write-Host "   [MISSING] $f" -ForegroundColor Red
    }
}

# 6. Recordatorios
Write-Host "`n[4/4] Recordatorios:" -ForegroundColor Yellow
Write-Host "   - web/ contiene la pagina web interactiva (JSP + Flutter)" -ForegroundColor White
Write-Host "   - recursos/codigo-ejemplo/ contiene el proyecto Maven" -ForegroundColor White
Write-Host "   - recursos/sql/ contiene el script PostgreSQL" -ForegroundColor White
Write-Host "   - recursos/docker/ contiene el Dockerfile" -ForegroundColor White
Write-Host "   - Puerto del sitio web: 8024" -ForegroundColor White
Write-Host "   - Jakarta EE 10 (jakarta.servlet.*, NO javax.servlet.*)" -ForegroundColor White

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "  Protocolo de inicio completado." -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
