from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from models.rol import RolDB
from schemas.usuario import Rol, RolCreate

router = APIRouter(prefix="/api/roles", tags=["Roles"])


@router.get("/", response_model=List[Rol])
async def listar_roles(db: Session = Depends(get_db)):
    return db.query(RolDB).all()


@router.post("/", response_model=Rol, status_code=201)
async def crear_rol(rol: RolCreate, db: Session = Depends(get_db)):
    existe = db.query(RolDB).filter(RolDB.nombre == rol.nombre).first()
    if existe:
        raise HTTPException(status_code=400, detail="El rol ya existe")
    db_rol = RolDB(**rol.model_dump())
    db.add(db_rol)
    db.commit()
    db.refresh(db_rol)
    return db_rol


@router.put("/{rol_id}", response_model=Rol)
async def actualizar_rol(rol_id: int, rol: RolCreate, db: Session = Depends(get_db)):
    db_rol = db.query(RolDB).filter(RolDB.id == rol_id).first()
    if not db_rol:
        raise HTTPException(status_code=404, detail="Rol no encontrado")
    for key, value in rol.model_dump().items():
        setattr(db_rol, key, value)
    db.commit()
    db.refresh(db_rol)
    return db_rol


@router.delete("/{rol_id}", status_code=204)
async def eliminar_rol(rol_id: int, db: Session = Depends(get_db)):
    db_rol = db.query(RolDB).filter(RolDB.id == rol_id).first()
    if not db_rol:
        raise HTTPException(status_code=404, detail="Rol no encontrado")
    db.delete(db_rol)
    db.commit()
    return None
