<#
.SYNOPSIS
    DevBrain Session End Protocol (Windows PowerShell)
    Protocolo de cierre de sesion de agente DevBrain.
    Proyecto: Guia JSP + MVC | SENA ADSO
#>
param(
    [switch]$AutoCommit,
    [switch]$SkipIntegrity
)

$ErrorActionPreference = "Continue"
$ProjectRoot = $PSScriptRoot | Split-Path -Parent
Set-Location $ProjectRoot

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  DevBrain Session End Protocol" -ForegroundColor Cyan
Write-Host "  Guia JSP + MVC | SENA ADSO" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Verificar archivos sin commitear
$uncommitted = git status --short 2>$null
if ($uncommitted) {
    Write-Host "`n[1/4] Archivos sin commit detectados:" -ForegroundColor Yellow
    Write-Host $uncommitted
    if ($AutoCommit) {
        git add -A
        $ts = Get-Date -Format "yyyy-MM-dd_HH:mm"
        git commit -m "session-end: cambios de sesion $ts"
        Write-Host "   Auto-commit realizado." -ForegroundColor Green
    } else {
        $resp = Read-Host "Deseas hacer commit automatico? (s/n)"
        if ($resp -eq "s") {
            git add -A
            $ts = Get-Date -Format "yyyy-MM-dd_HH:mm"
            git commit -m "session-end: cambios de sesion $ts"
        } else {
            Write-Host "ABORTADO - No puedes cerrar sesion con archivos sin commit" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "`n[1/4] Sin archivos pendientes" -ForegroundColor Green
}

# 2. Verificar que el sitio web esta intacto
Write-Host "`n[2/4] Verificando archivos del sitio web..." -ForegroundColor Yellow
$webFiles = @("web\index.html", "web\css\styles.css", "web\js\main.js")
$allOk = $true
foreach ($f in $webFiles) {
    if (-not (Test-Path $f)) {
        Write-Host "   [MISSING] $f" -ForegroundColor Red
        $allOk = $false
    }
}
if ($allOk) {
    Write-Host "   Todos los archivos del sitio web estan presentes" -ForegroundColor Green
}

# 3. Verificar integridad
if (-not $SkipIntegrity) {
    Write-Host "`n[3/4] Verificando integridad..." -ForegroundColor Yellow
    if (Test-Path "$PSScriptRoot\integrity-check.ps1") {
        & "$PSScriptRoot\integrity-check.ps1" -Fast
    } else {
        Write-Host "   Skip (no hay integrity-check.ps1)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "`n[3/4] Skip integrity check" -ForegroundColor DarkGray
}

# 4. Recordatorios finales
Write-Host "`n[4/4] Si aprendiste algo nuevo, registralo en:" -ForegroundColor Yellow
Write-Host "   .devbrain\knowledge\lessons_learned.md" -ForegroundColor DarkGray

# 5. Tag de fin de sesion
$tag = "session-end-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
git tag $tag 2>$null | Out-Null
Write-Host "`n   Tag creado: $tag" -ForegroundColor Green

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "  Protocolo de cierre completado." -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
