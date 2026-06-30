<#
.SYNOPSIS
    Task runner para el proyecto Full Stack SENA ADSO.
    Equivalente a Makefile pero para PowerShell.
    
    Uso:
        .\Makefile.ps1 <tarea>
    
    Tareas disponibles:
        help        → Muestra esta ayuda
        install     → Instala dependencias de todos los proyectos
        api         → Inicia FastAPI (desarrollo)
        frontend    → Inicia React (desarrollo)
        fullstack   → Inicia todo (usa start-fullstack.ps1)
        test        → Ejecuta pruebas de FastAPI
        db-create   → Crea la base de datos en PostgreSQL
        db-migrate  → Ejecuta migraciones Alembic
        db-revision → Crea nueva migración Alembic
        docker-up   → Levanta contenedores Docker
        docker-down → Detiene contenedores
        clean       → Limpia archivos temporales
#>

param(
    [Parameter(Position = 0)]
    [ValidateSet("help", "install", "api", "frontend", "fullstack", "test",
                 "db-create", "db-migrate", "db-revision", "docker-up",
                 "docker-down", "clean", "status")]
    [string]$Task = "help"
)

$ProjectRoot = "$PSScriptRoot"
$FastApiDir = "$ProjectRoot\recursos\fastapi-inventario"
$ReactDir = "$ProjectRoot\recursos\frontend-inventario"
$PythonVenv = "$FastApiDir\venv"

function Write-Title { param([string]$T) Write-Host "`n=== $T ===" -ForegroundColor Cyan }

switch ($Task) {
    "help" {
        Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║  Makefile.ps1 — Full Stack Task Runner       ║" -ForegroundColor Cyan
        Write-Host "╠══════════════════════════════════════════════╣" -ForegroundColor Cyan
        Get-ChildItem function: | Where-Object { $_.Name -eq "prompt" -or $_.Name -eq "Write-Title" } | Out-Null
        $tasks = @(
            @("help",        "Muestra esta ayuda"),
            @("install",     "Instala dependencias de todos los proyectos"),
            @("api",         "Inicia FastAPI (desarrollo con --reload)"),
            @("frontend",    "Inicia React (desarrollo con Vite)"),
            @("fullstack",   "Inicia todo (start-fullstack.ps1)"),
            @("test",        "Ejecuta pruebas de FastAPI con pytest"),
            @("db-create",   "Crea la base de datos inventario_db"),
            @("db-migrate",  "Ejecuta migraciones Alembic pendientes"),
            @("db-revision", "Crea nueva migración Alembic automática"),
            @("docker-up",   "docker compose up -d"),
            @("docker-down", "docker compose down"),
            @("clean",       "Limpia __pycache__, node_modules/.cache"),
            @("status",      "Muestra estado de todos los servicios")
        )
        foreach ($t in $tasks) {
            Write-Host "  $($t[0].PadRight(15)) $($t[1])" -ForegroundColor White
        }
        Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host "`nUso: .\Makefile.ps1 <tarea>" -ForegroundColor Yellow
    }

    "install" {
        Write-Title "Instalando dependencias"

        Write-Host "[FastAPI] Instalando Python packages..." -ForegroundColor Yellow
        if (-not (Test-Path "$PythonVenv\Scripts\python.exe")) { python -m venv $PythonVenv }
        & "$PythonVenv\Scripts\pip.exe" install -q -r "$FastApiDir\requirements.txt"
        & "$PythonVenv\Scripts\pip.exe" install -q alembic pytest httpx
        Write-Host "  ✅ FastAPI dependencies installed" -ForegroundColor Green

        Write-Host "[React] Instalando npm packages..." -ForegroundColor Yellow
        & npm install --prefix "$ReactDir" 2>$null
        Write-Host "  ✅ React dependencies installed" -ForegroundColor Green
    }

    "api" {
        Write-Title "Iniciando FastAPI en http://localhost:8000"
        Write-Host "Swagger: http://localhost:8000/docs" -ForegroundColor Cyan
        if (-not (Test-Path "$PythonVenv\Scripts\Activate.ps1")) { python -m venv $PythonVenv }
        & "$PythonVenv\Scripts\pip.exe" install -q -r "$FastApiDir\requirements.txt" 2>$null
        & "$PythonVenv\Scripts\python.exe" -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
    }

    "frontend" {
        Write-Title "Iniciando React en http://localhost:5173"
        & npm run dev --prefix "$ReactDir"
    }

    "fullstack" {
        & "$ProjectRoot\start-fullstack.ps1"
    }

    "test" {
        Write-Title "Ejecutando pruebas de FastAPI"
        $env:PYTHONPATH = "$FastApiDir"
        & "$PythonVenv\Scripts\pip.exe" install -q pytest httpx 2>$null
        & "$PythonVenv\Scripts\python.exe" -m pytest "$FastApiDir\tests" -v
    }

    "db-create" {
        Write-Title "Creando base de datos inventario_db"
        try {
            $result = & psql -U postgres -c "CREATE DATABASE inventario_db;" 2>&1
            Write-Host "  ✅ Base de datos creada" -ForegroundColor Green
        } catch {
            Write-Host "  ℹ️  Ya existe o error: $_" -ForegroundColor Yellow
        }
        # Ejecutar script SQL
        & psql -U postgres -d inventario_db -f "$ProjectRoot\recursos\sql\inventario_db.sql"
        Write-Host "  ✅ Tablas creadas" -ForegroundColor Green
    }

    "db-migrate" {
        Write-Title "Ejecutando migraciones Alembic"
        Push-Location $FastApiDir
        & "$PythonVenv\Scripts\alembic.exe" upgrade head
        Pop-Location
    }

    "db-revision" {
        $msg = Read-Host "Descripcion de la migracion"
        Push-Location $FastApiDir
        & "$PythonVenv\Scripts\alembic.exe" revision --autogenerate -m "$msg"
        Pop-Location
    }

    "docker-up" {
        Write-Title "Levantando contenedores Docker"
        $compose = Read-Host "Compose file (default: docker-compose.fullstack.yml)"
        if (-not $compose) { $compose = "docker-compose.fullstack.yml" }
        docker compose -f $compose up -d
    }

    "docker-down" {
        Write-Title "Deteniendo contenedores Docker"
        $compose = Read-Host "Compose file (default: docker-compose.fullstack.yml)"
        if (-not $compose) { $compose = "docker-compose.fullstack.yml" }
        docker compose -f $compose down
    }

    "clean" {
        Write-Title "Limpiando archivos temporales"
        Get-ChildItem -Path $FastApiDir -Filter "__pycache__" -Recurse -Directory | Remove-Item -Recurse -Force 2>$null
        Get-ChildItem -Path $ReactDir -Filter "node_modules/.cache" -Recurse -Directory | Remove-Item -Recurse -Force 2>$null
        Write-Host "  ✅ Temporary files cleaned" -ForegroundColor Green
    }

    "status" {
        & "$ProjectRoot\start-fullstack.ps1" -Status
    }
}
