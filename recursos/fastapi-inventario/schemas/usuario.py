from pydantic import BaseModel, Field, EmailStr, ConfigDict
from datetime import datetime
from typing import Optional


class RolBase(BaseModel):
    nombre: str = Field(..., min_length=3, max_length=50)
    descripcion: Optional[str] = None


class RolCreate(RolBase):
    pass


class Rol(RolBase):
    id: int
    estado: bool = True
    fecha_creacion: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)


class UsuarioBase(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    nombre_completo: str = Field(..., min_length=3, max_length=100)
    email: EmailStr
    rol_id: int


class UsuarioCreate(UsuarioBase):
    password: str = Field(..., min_length=6)


class Usuario(UsuarioBase):
    id: int
    estado: bool = True
    fecha_creacion: Optional[datetime] = None
    rol: Optional[Rol] = None

    model_config = ConfigDict(from_attributes=True)


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    usuario: Usuario
