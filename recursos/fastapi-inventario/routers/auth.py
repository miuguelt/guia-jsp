from datetime import datetime, timedelta, timezone
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from passlib.context import CryptContext

from config import settings
from database import get_db
from models.usuario import UsuarioDB
from schemas.usuario import LoginRequest, TokenResponse, Usuario, UsuarioCreate

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()
router = APIRouter(prefix="/api/auth", tags=["Autenticación"])


# =========================================================================
# Funciones auxiliares
# =========================================================================

def crear_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Genera un JWT con expiración desde config."""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(minutes=settings.access_token_expire_minutes)
    )
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)


def obtener_usuario_actual(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> UsuarioDB:
    """Valida el token JWT y retorna el usuario autenticado."""
    token = credentials.credentials
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Token inválido")
    except JWTError:
        raise HTTPException(status_code=401, detail="Token inválido o expirado")

    usuario = db.query(UsuarioDB).filter(UsuarioDB.username == username).first()
    if usuario is None:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")
    return usuario


def verificar_rol(roles_permitidos: list[str]):
    """Factory que retorna una dependencia para verificar roles.
    
    Uso:
        @router.get("/admin-only", dependencies=[Depends(verificar_rol(["Admin"]))])
    """
    def verificador(usuario: UsuarioDB = Depends(obtener_usuario_actual)):
        if usuario.rol.nombre not in roles_permitidos:
            raise HTTPException(
                status_code=403,
                detail=f"Acceso denegado. Se requiere rol: {', '.join(roles_permitidos)}",
            )
        return usuario
    return verificador


# =========================================================================
# Endpoints
# =========================================================================

@router.post("/register", response_model=Usuario, status_code=201)
async def register(usuario: UsuarioCreate, db: Session = Depends(get_db)):
    """Registra un nuevo usuario con password hasheado (BCrypt)."""
    existe = db.query(UsuarioDB).filter(
        (UsuarioDB.username == usuario.username) | (UsuarioDB.email == usuario.email)
    ).first()
    if existe:
        raise HTTPException(status_code=400, detail="Usuario o email ya existe")

    db_usuario = UsuarioDB(
        username=usuario.username,
        password=pwd_context.hash(usuario.password),
        nombre_completo=usuario.nombre_completo,
        email=usuario.email,
        rol_id=usuario.rol_id,
    )
    db.add(db_usuario)
    db.commit()
    db.refresh(db_usuario)
    return db_usuario


@router.post("/login", response_model=TokenResponse)
async def login(creds: LoginRequest, db: Session = Depends(get_db)):
    """Valida credenciales (BCrypt) y retorna JWT + datos del usuario."""
    usuario = db.query(UsuarioDB).filter(UsuarioDB.username == creds.username).first()

    if not usuario or not pwd_context.verify(creds.password, usuario.password):
        raise HTTPException(status_code=401, detail="Credenciales inválidas")

    if not usuario.estado:
        raise HTTPException(status_code=403, detail="Usuario inactivo")

    token = crear_token(
        data={"sub": usuario.username, "rol": usuario.rol.nombre},
    )
    return TokenResponse(access_token=token, usuario=Usuario.model_validate(usuario))


@router.get("/me", response_model=Usuario)
async def perfil_actual(
    usuario: UsuarioDB = Depends(obtener_usuario_actual),
):
    """Retorna el perfil del usuario autenticado. Requiere JWT."""
    return usuario


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    usuario: UsuarioDB = Depends(obtener_usuario_actual),
):
    """Genera un nuevo JWT antes de que expire."""
    token = crear_token(
        data={"sub": usuario.username, "rol": usuario.rol.nombre},
    )
    return TokenResponse(access_token=token, usuario=Usuario.model_validate(usuario))
