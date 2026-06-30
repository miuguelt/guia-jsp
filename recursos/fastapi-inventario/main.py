import logging
import sys
from contextlib import asynccontextmanager
from datetime import datetime, timezone

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from config import settings
from database import engine, Base
from routers import producto as producto_router
from routers import auth as auth_router
from routers import usuario as usuario_router
from routers import rol as rol_router

# =========================================================================
# Configuración de logging
# =========================================================================
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[
        logging.StreamHandler(sys.stdout),  # Consola
        logging.FileHandler("api.log"),     # Archivo
    ],
)
logger = logging.getLogger("api")


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    logger.info("Tablas creadas/verificadas en la base de datos")
    yield


app = FastAPI(
    lifespan=lifespan,
    title="API Inventario - SENA ADSO",
    description="API REST del sistema de inventario. Incluye autenticación JWT, "
                "CRUD de productos, usuarios y roles con relaciones FK, "
                "paginación, logging y manejo global de errores.",
    version="2.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# =========================================================================
# CORS
# =========================================================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_methods=["*"],
    allow_headers=["*"],
    allow_credentials=True,
)

# =========================================================================
# Manejadores globales de errores
# =========================================================================

@app.exception_handler(ValueError)
async def value_error_handler(request: Request, exc: ValueError):
    """Captura errores de validación de Python estándar."""
    logger.warning(f"ValueError: {exc} — {request.url}")
    return JSONResponse(
        status_code=400,
        content={"detail": str(exc), "error_code": "VALIDATION_ERROR"},
    )


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Captura cualquier excepción no manejada."""
    logger.error(f"Error no manejado: {exc} — {request.url}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Error interno del servidor",
            "error_code": "INTERNAL_ERROR",
            "timestamp": datetime.now(timezone.utc).isoformat(),
        },
    )


# =========================================================================
# Middleware: log de todas las peticiones
# =========================================================================

@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Registra cada petición HTTP con método, ruta y status."""
    start = datetime.now()
    response = await call_next(request)
    elapsed = (datetime.now() - start).total_seconds()
    logger.info(
        f"{request.method} {request.url.path} → {response.status_code} "
        f"({elapsed:.3f}s)"
    )
    return response


# =========================================================================
# Routers
# =========================================================================
app.include_router(producto_router.router)
app.include_router(auth_router.router)
app.include_router(usuario_router.router)
app.include_router(rol_router.router)


# =========================================================================
# Endpoints raíz
# =========================================================================

@app.get("/")
async def root():
    return {
        "mensaje": "API Inventario - SENA ADSO",
        "version": "2.1.0",
        "auth": "/docs#/Autenticación",
        "paginacion": "GET /api/productos/?pagina=1&tamano=10",
        "endpoints": {
            "auth": {
                "POST /api/auth/register": "Registro de usuarios",
                "POST /api/auth/login": "Inicio de sesión (retorna JWT)",
                "GET /api/auth/me": "Perfil del usuario autenticado",
            },
            "productos": {
                "GET /api/productos/": "Listar productos (paginado)",
                "POST /api/productos/": "Crear producto (JWT)",
                "GET /api/productos/{id}": "Obtener producto",
                "PUT /api/productos/{id}": "Actualizar producto (JWT)",
                "DELETE /api/productos/{id}": "Eliminar producto (JWT)",
            },
            "usuarios": {
                "GET /api/usuarios/": "Listar usuarios (Admin)",
                "PUT /api/usuarios/{id}": "Actualizar usuario (Admin)",
                "DELETE /api/usuarios/{id}": "Eliminar usuario (Admin)",
            },
        },
    }


@app.get("/health")
async def health_check():
    return {
        "status": "ok",
        "database": "conectada",
        "auth": "JWT habilitado",
        "logging": "activo",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
