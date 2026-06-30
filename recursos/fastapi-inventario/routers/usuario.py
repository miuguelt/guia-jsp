from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from models.usuario import UsuarioDB
from schemas.usuario import Usuario, UsuarioCreate
from routers.auth import obtener_usuario_actual, verificar_rol

router = APIRouter(prefix="/api/usuarios", tags=["Usuarios"])


@router.get("/", response_model=List[Usuario])
async def listar_usuarios(
    db: Session = Depends(get_db),
    usuario: UsuarioDB = Depends(verificar_rol(["Administrador"])),
):
    """Solo administradores pueden listar usuarios."""
    return db.query(UsuarioDB).all()


@router.get("/{usuario_id}", response_model=Usuario)
async def obtener_usuario(
    usuario_id: int,
    db: Session = Depends(get_db),
    usuario: UsuarioDB = Depends(verificar_rol(["Administrador"])),
):
    db_user = db.query(UsuarioDB).filter(UsuarioDB.id == usuario_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return db_user


@router.put("/{usuario_id}", response_model=Usuario)
async def actualizar_usuario(
    usuario_id: int,
    data: UsuarioCreate,
    db: Session = Depends(get_db),
    usuario: UsuarioDB = Depends(verificar_rol(["Administrador"])),
):
    db_user = db.query(UsuarioDB).filter(UsuarioDB.id == usuario_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    db_user.username = data.username
    db_user.nombre_completo = data.nombre_completo
    db_user.email = data.email
    db_user.rol_id = data.rol_id

    db.commit()
    db.refresh(db_user)
    return db_user


@router.delete("/{usuario_id}", status_code=204)
async def eliminar_usuario(
    usuario_id: int,
    db: Session = Depends(get_db),
    usuario: UsuarioDB = Depends(verificar_rol(["Administrador"])),
):
    db_user = db.query(UsuarioDB).filter(UsuarioDB.id == usuario_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    db.delete(db_user)
    db.commit()
    return None
