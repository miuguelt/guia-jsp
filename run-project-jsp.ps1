<#
.SYNOPSIS
    Script de inicio automatizado para el Sistema de Inventario JSP + MVC.
    Verifica puertos, base de datos e inicia Tomcat de forma transparente.
.DESCRIPTION
    Este script facilita al aprendiz la ejecución de la aplicación Java.
    Verifica conflictos en el puerto 8080 y la conexión a PostgreSQL.
#>

$ErrorActionPreference = "Stop"
$PortApp = 8080
$PortDb = 5432
$ProjectRoot = "$PSScriptRoot"
$JavaProjDir = "$ProjectRoot\recursos\codigo-ejemplo"
$SqlScript = "$ProjectRoot\recursos\sql\inventario_db.sql"

# Banner Institucional SENA
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     SENA ADSO - INICIALIZADOR DE PROYECTO JSP + MVC     " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Este script automatiza el arranque de su primer proyecto." -ForegroundColor Gray
Write-Host ""

# 1. Verificar y Liberar Puerto 8080 (Tomcat / Cargo)
Write-Host "[1/4] Verificando puerto $PortApp para Tomcat..." -ForegroundColor Yellow
$connApp = Get-NetTCPConnection -LocalPort $PortApp -ErrorAction SilentlyContinue
if ($connApp) {
    Write-Host "  [!] El puerto $PortApp ya está en uso por el proceso con PID: $($connApp.OwningProcess[0])" -ForegroundColor LightRed
    Write-Host "  [i] Intentando liberar el puerto en cascada..." -ForegroundColor Gray
    foreach ($c in $connApp) {
        if ($c.OwningProcess -gt 0) {
            Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue
        }
    }
    Start-Sleep -Seconds 1
    $connAppCheck = Get-NetTCPConnection -LocalPort $PortApp -ErrorAction SilentlyContinue
    if ($connAppCheck) {
        Write-Host "  [Error] No se pudo liberar el puerto $PortApp automáticamente. Detenga el proceso manualmente." -ForegroundColor Red
        Exit
    } else {
        Write-Host "  [OK] Puerto $PortApp liberado con éxito." -ForegroundColor Green
    }
} else {
    Write-Host "  [OK] Puerto $PortApp disponible." -ForegroundColor Green
}

# 2. Verificar PostgreSQL (Puerto 5432)
Write-Host ""
Write-Host "[2/4] Verificando servicio de Base de Datos PostgreSQL..." -ForegroundColor Yellow
$connDb = Get-NetTCPConnection -LocalPort $PortDb -ErrorAction SilentlyContinue
if (-not $connDb) {
    Write-Host "  [!] PostgreSQL no está activo en el puerto $PortDb." -ForegroundColor LightRed
    
    # Intentar Docker Compose para la DB si está instalado
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if ($docker) {
        Write-Host "  [i] Docker detectado. Levantando contenedor de base de datos PostgreSQL..." -ForegroundColor Gray
        try {
            Start-Process -FilePath "docker" -ArgumentList "compose", "up", "-d", "db" -WorkingDirectory $ProjectRoot -NoNewWindow -Wait
            Write-Host "  [i] Esperando a que PostgreSQL esté listo..." -ForegroundColor Gray
            Start-Sleep -Seconds 5
            $connDb = Get-NetTCPConnection -LocalPort $PortDb -ErrorAction SilentlyContinue
        } catch {
            Write-Host "  [Error] Falló la inicialización de PostgreSQL mediante Docker." -ForegroundColor Red
        }
    }
    
    if (-not $connDb) {
        Write-Host "  [!] Asegúrese de tener PostgreSQL activo nativamente o mediante Docker." -ForegroundColor Yellow
        Write-Host "  Pulse ENTER para continuar intentando arrancar la aplicación Java de todas formas..." -ForegroundColor DarkGray
        Read-Host
    }
}

if ($connDb) {
    Write-Host "  [OK] PostgreSQL está activo en el puerto $PortDb." -ForegroundColor Green
    
    # Intentar inicializar la base de datos si psql está disponible
    $psql = Get-Command psql -ErrorAction SilentlyContinue
    if ($psql) {
        Write-Host "  [i] Herramienta 'psql' detectada. Asegurando base de datos 'inventario_db'..." -ForegroundColor Gray
        try {
            # Intentar crear base de datos (ignorar error si ya existe)
            $env:PGPASSWORD = "postgres"
            & psql -U postgres -h localhost -c "CREATE DATABASE inventario_db;" 2>$null | Out-Null
            
            # Cargar tablas
            Write-Host "  [i] Ejecutando script SQL de inicialización..." -ForegroundColor Gray
            & psql -U postgres -h localhost -d inventario_db -f "$SqlScript" > $null
            Write-Host "  [OK] Base de datos 'inventario_db' inicializada correctamente." -ForegroundColor Green
        } catch {
            Write-Host "  [!] No se pudo inicializar la base de datos automáticamente (verifique credenciales postgres/postgres)." -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [i] 'psql' no está en el PATH. Si es la primera vez que ejecuta el proyecto," -ForegroundColor Gray
        Write-Host "      asegúrese de haber creado la BD 'inventario_db' y cargado el archivo:" -ForegroundColor Gray
        Write-Host "      $SqlScript" -ForegroundColor Cyan
    }
}

# 3. Compilación con Maven
Write-Host ""
Write-Host "[3/4] Compilando el proyecto con Maven..." -ForegroundColor Yellow
if (-not (Test-Path "$JavaProjDir\pom.xml")) {
    Write-Host "  [Error] No se encontró pom.xml en $JavaProjDir" -ForegroundColor Red
    Exit
}

try {
    Start-Process -FilePath "mvn" -ArgumentList "clean", "package", "-DskipTests" -WorkingDirectory $JavaProjDir -NoNewWindow -Wait
    Write-Host "  [OK] Proyecto compilado correctamente." -ForegroundColor Green
} catch {
    Write-Host "  [Error] Error al ejecutar Maven (mvn). ¿Está instalado y en el PATH?" -ForegroundColor Red
    Exit
}

# 4. Arrancar Servidor Tomcat vía Cargo
Write-Host ""
Write-Host "[4/4] Iniciando Tomcat 10 e instalando aplicación..." -ForegroundColor Yellow
Write-Host "      (La primera vez tomará unos instantes mientras se descarga Tomcat automáticamente)" -ForegroundColor Gray
Write-Host "      Para detener el servidor, presione Ctrl+C en esta ventana." -ForegroundColor Cyan
Write-Host ""

# Abrir el navegador tras un breve delay
Start-ThreadJob -ScriptBlock {
    Start-Sleep -Seconds 6
    Write-Host "`n[i] Abriendo navegador en http://localhost:8080/inventario-mvc-1.0/ ..." -ForegroundColor Green
    Start-Process "http://localhost:8080/inventario-mvc-1.0/"
}

try {
    # Ejecutar Cargo en primer plano para ver los logs y poder cancelarlo con Ctrl+C
    Set-Location -Path $JavaProjDir
    mvn cargo:run
} catch {
    Write-Host "`n[Error] El servidor de aplicaciones se ha detenido o no pudo iniciar." -ForegroundColor Red
}
