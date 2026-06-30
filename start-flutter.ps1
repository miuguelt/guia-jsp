<#
.SYNOPSIS
    Inicia el stack completo de Flutter + Microservicios para la guia SENA ADSO
.DESCRIPTION
    Este script levanta los microservicios FastAPI con Docker y la app Flutter
    en modo desarrollo web. Requiere Docker Desktop y Flutter SDK instalados.
.NOTES
    Version: 1.0
    Author: SENA ADSO - Programa 228123
#>

$ErrorActionPreference = "Stop"
$ROOT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Header {
    param([string]$Text)
    Write-Host "`n" -NoNewline
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Text, [string]$Status = "INFO")
    $color = switch ($Status) {
        "OK"    { "Green" }
        "WARN"  { "Yellow" }
        "ERROR" { "Red" }
        default { "White" }
    }
    Write-Host "[$Status] $Text" -ForegroundColor $color
}

function Test-Command {
    param([string]$Command)
    return Get-Command $Command -ErrorAction SilentlyContinue
}

# ============================================
# VALIDACION DE REQUISITOS
# ============================================
Write-Header "VALIDANDO REQUISITOS"

$hasDocker = Test-Command "docker"
if (-not $hasDocker) {
    Write-Step "Docker no encontrado. Instala Docker Desktop primero." "ERROR"
    Write-Step "Descargar: https://www.docker.com/products/docker-desktop/" "WARN"
    exit 1
}
Write-Step "Docker: $(docker --version)" "OK"

$hasFlutter = Test-Command "flutter"
if (-not $hasFlutter) {
    Write-Step "Flutter no encontrado. Verifica que este en el PATH." "WARN"
    Write-Step "La app Flutter no se iniciara, pero los microservicios funcionaran." "WARN"
    $skipFlutter = $true
} else {
    Write-Step "Flutter: $(flutter --version --machine | python -c 'import sys,json; d=json.load(sys.stdin); print(d.get(\"flutterVersion\",\"\"))' 2>$null)" "OK"
    $skipFlutter = $false
}

# ============================================
# INICIAR MICROSERVICIOS
# ============================================
Write-Header "INICIANDO MICROSERVICIOS CON DOCKER"

# Verificar si los contenedores ya estan corriendo
$running = docker compose -f "$ROOT_DIR/docker-compose.microservices.yml" ps -q 2>$null
if ($running) {
    Write-Step "Microservicios ya estan en ejecucion. Recargando..." "WARN"
    docker compose -f "$ROOT_DIR/docker-compose.microservices.yml" down
}

Write-Step "Construyendo e iniciando microservicios (auth, products, users, db)..."
docker compose -f "$ROOT_DIR/docker-compose.microservices.yml" up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Step "Error al iniciar microservicios." "ERROR"
    exit 1
}

Write-Step "Microservicios iniciados correctamente." "OK"

# Esperar a que los servicios esten saludables
Write-Step "Esperando que los servicios esten listos..."
$services = @("auth-service", "products-service", "users-service")
foreach ($svc in $services) {
    $retries = 30
    $ready = $false
    while ($retries -gt 0 -and -not $ready) {
        $port = switch ($svc) {
            "auth-service"    { 8001 }
            "products-service" { 8002 }
            "users-service"   { 8003 }
        }
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$port/docs" -Method GET -TimeoutSec 2 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                $ready = $true
            }
        } catch {
            # Aun no esta listo
        }
        if (-not $ready) {
            Start-Sleep -Seconds 2
            $retries--
        }
    }
    if ($ready) {
        Write-Step "$svc listo en http://localhost:$port/docs" "OK"
    } else {
        Write-Step "$svc no respondio a tiempo. Verifica los logs." "WARN"
    }
}

# ============================================
# MOSTRAR SERVICIOS DISPONIBLES
# ============================================
Write-Header "SERVICIOS DISPONIBLES"

$servicesInfo = @(
    @{Name="Auth Service"; URL="http://localhost:8001/docs"; Desc="Autenticacion JWT"},
    @{Name="Products Service"; URL="http://localhost:8002/docs"; Desc="CRUD de Productos"},
    @{Name="Users Service"; URL="http://localhost:8003/docs"; Desc="CRUD de Usuarios"},
    @{Name="API Gateway"; URL="http://localhost:8000/api"; Desc="Entrada unificada (puerto 8000)"}
)

$servicesInfo | ForEach-Object {
    Write-Host "  $($_.Name): " -NoNewline -ForegroundColor Yellow
    Write-Host $_.URL -ForegroundColor Cyan
    Write-Host "    $($_.Desc)" -ForegroundColor DarkGray
}

# ============================================
# INICIAR FLUTTER
# ============================================
if (-not $skipFlutter) {
    Write-Header "INICIANDO APP FLUTTER"
    
    $flutterDir = "$ROOT_DIR/recursos/flutter-inventario"
    
    if (-not (Test-Path $flutterDir)) {
        Write-Step "Directorio flutter-inventario no encontrado." "ERROR"
        Write-Step "Ejecuta este script desde la raiz del proyecto guia-jsp." "WARN"
        exit 1
    }
    
    Set-Location $flutterDir
    
    Write-Step "Instalando dependencias Flutter..."
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-Step "Error al instalar dependencias." "ERROR"
        exit 1
    }
    Write-Step "Dependencias instaladas." "OK"
    
    Write-Step "Iniciando Flutter en Chrome (puerto 3000)..."
    Write-Step "La app se abrira automaticamente en el navegador." "INFO"
    Write-Step "Para emulador Android, ejecuta: flutter run" "INFO"
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$flutterDir'; flutter run -d chrome --web-port 3000"
    
    Start-Sleep -Seconds 5
    Write-Step "Flutter iniciado en http://localhost:3000" "OK"
}

# ============================================
# RESUMEN FINAL
# ============================================
Write-Header "STACK COMPLETO INICIADO"
Write-Host @"

  Microservicios:
    Auth:      http://localhost:8001/docs
    Products:  http://localhost:8002/docs
    Users:     http://localhost:8003/docs
    
  App Flutter:
    Web:       http://localhost:3000
    
  Guia Web:
    JSP:       $ROOT_DIR/web/index.html
    Flutter:   $ROOT_DIR/web/flutter-guide.html

  Comandos utiles:
    Detener todo: docker compose -f docker-compose.microservices.yml down
    Logs:        docker compose -f docker-compose.microservices.yml logs -f
    Reconstruir: docker compose -f docker-compose.microservices.yml up -d --build

"@ -ForegroundColor Green
