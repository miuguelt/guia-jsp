<#
.SYNOPSIS
    DevBrain Integrity Check (Windows PowerShell)
    Verifica la integridad de archivos criticos del proyecto.
#>
param(
    [switch]$Fast
)

$ErrorActionPreference = "Continue"
$ProjectRoot = $PSScriptRoot | Split-Path -Parent
Set-Location $ProjectRoot

Write-Host "[DevBrain] Verificando integridad..." -ForegroundColor Cyan

$errors = 0

# Archivos criticos del sitio web
$webFiles = @(
    "web\index.html",
    "web\css\styles.css",
    "web\js\main.js"
)

foreach ($f in $webFiles) {
    if (-not (Test-Path $f)) {
        Write-Host "   [MISSING] $f" -ForegroundColor Red
        $errors++
    } else {
        Write-Host "   [OK] $f" -ForegroundColor Green
    }
}

# Archivos criticos de recursos
$resourceFiles = @(
    "recursos\sql\inventario_db.sql",
    "recursos\docker\Dockerfile",
    "recursos\codigo-ejemplo\pom.xml"
)

foreach ($f in $resourceFiles) {
    if (-not (Test-Path $f)) {
        Write-Host "   [MISSING] $f" -ForegroundColor Red
        $errors++
    } else {
        Write-Host "   [OK] $f" -ForegroundColor Green
    }
}

if (-not $Fast) {
    # Verificar clases Java del modelo
    $javaFiles = @(
        "recursos\codigo-ejemplo\src\main\java\com\sena\inventario\modelo\Producto.java",
        "recursos\codigo-ejemplo\src\main\java\com\sena\inventario\modelo\Usuario.java",
        "recursos\codigo-ejemplo\src\main\java\com\sena\inventario\modelo\Rol.java",
        "recursos\codigo-ejemplo\src\main\java\com\sena\inventario\dao\ProductoDAO.java",
        "recursos\codigo-ejemplo\src\main\java\com\sena\inventario\dao\ConexionDB.java",
        "recursos\codigo-ejemplo\src\main\java\com\sena\inventario\controlador\ProductoServlet.java"
    )
    
    foreach ($f in $javaFiles) {
        if (-not (Test-Path $f)) {
            Write-Host "   [MISSING] $f" -ForegroundColor Red
            $errors++
        } else {
            Write-Host "   [OK] $f" -ForegroundColor Green
        }
    }
}

if ($errors -eq 0) {
    Write-Host "`nIntegridad OK - Todos los archivos criticos presentes" -ForegroundColor Green
} else {
    Write-Host "`n$errors archivo(s) faltante(s) detectado(s)" -ForegroundColor Red
}
