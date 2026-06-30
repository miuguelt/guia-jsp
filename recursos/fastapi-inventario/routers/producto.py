import logging

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from database import get_db
from models.producto import ProductoDB
from schemas.producto import Producto, ProductoCreate, PaginatedResponse
from routers.auth import obtener_usuario_actual
from models.usuario import UsuarioDB

logger = logging.getLogger("api.productos")
router = APIRouter(prefix="/api/productos", tags=["Productos"])


@router.get("/", response_model=PaginatedResponse)
async def listar_productos(
    categoria: Optional[str] = None,
    pagina: int = Query(1, ge=1, description="Número de página"),
    tamano: int = Query(10, ge=1, le=100, description="Items por página"),
    db: Session = Depends(get_db),
):
    """GET /api/productos/?pagina=1&tamano=10&categoria=Tecnologia
    
    Retorna lista paginada de productos.
    - pagina: número de página (empieza en 1)
    - tamano: items por página (máx 100)
    - categoria: filtro opcional
    """
    query = db.query(ProductoDB)
    if categoria:
        query = query.filter(ProductoDB.categoria == categoria)

    total = query.count()
    offset = (pagina - 1) * tamano
    productos = query.offset(offset).limit(tamano).all()

    return PaginatedResponse(
        items=productos,
        total=total,
        pagina=pagina,
        tamano=tamano,
        total_paginas=(total + tamano - 1) // tamano,
    )


@router.get("/{producto_id}", response_model=Producto)
async def obtener_producto(producto_id: int, db: Session = Depends(get_db)):
    """GET /api/productos/5 — Obtener producto por ID."""
    producto = db.query(ProductoDB).filter(ProductoDB.id == producto_id).first()
    if not producto:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return producto


@router.post("/", response_model=Producto, status_code=status.HTTP_201_CREATED)
async def crear_producto(
    producto: ProductoCreate,
    db: Session = Depends(get_db),
    usuario: UsuarioDB = Depends(obtener_usuario_actual),
):
    """POST /api/productos — Crear producto (requiere JWT)."""
    db_producto = ProductoDB(**producto.model_dump(), usuario_creador_id=usuario.id)
    db.add(db_producto)
    db.commit()
    db.refresh(db_producto)
    logger.info(f"Producto creado ID={db_producto.id} por usuario={usuario.username}")
    return db_producto


@router.put("/{producto_id}", response_model=Producto)
async def actualizar_producto(
    producto_id: int,
    producto: ProductoCreate,
    db: Session = Depends(get_db),
    usuario: UsuarioDB = Depends(obtener_usuario_actual),
):
    """PUT /api/productos/5 — Actualizar producto (requiere JWT)."""
    db_producto = db.query(ProductoDB).filter(ProductoDB.id == producto_id).first()
    if not db_producto:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    for key, value in producto.model_dump().items():
        setattr(db_producto, key, value)
    db_producto.usuario_creador_id = usuario.id
    db.commit()
    db.refresh(db_producto)
    logger.info(f"Producto ID={producto_id} actualizado por usuario={usuario.username}")
    return db_producto


@router.delete("/{producto_id}", status_code=status.HTTP_204_NO_CONTENT)
async def eliminar_producto(
    producto_id: int,
    db: Session = Depends(get_db),
    usuario: UsuarioDB = Depends(obtener_usuario_actual),
):
    """DELETE /api/productos/5 — Eliminar producto (requiere JWT)."""
    db_producto = db.query(ProductoDB).filter(ProductoDB.id == producto_id).first()
    if not db_producto:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    db.delete(db_producto)
    db.commit()
    logger.info(f"Producto ID={producto_id} eliminado por usuario={usuario.username}")
    return None
