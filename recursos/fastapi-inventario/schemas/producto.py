from pydantic import BaseModel, Field, ConfigDict
from decimal import Decimal
from datetime import datetime
from typing import Optional, Generic, TypeVar

T = TypeVar("T")


class ProductoBase(BaseModel):
    codigo: str = Field(..., min_length=3, max_length=50)
    nombre: str = Field(..., min_length=2, max_length=100)
    descripcion: Optional[str] = None
    precio: Decimal = Field(..., gt=0, decimal_places=2)
    stock: int = Field(default=0, ge=0)
    categoria: Optional[str] = None


class ProductoCreate(ProductoBase):
    pass


class Producto(ProductoBase):
    id: int
    estado: bool = True
    usuario_creador_id: Optional[int] = None
    fecha_registro: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)


class PaginatedResponse(BaseModel, Generic[T]):
    """Respuesta paginada estándar para listas."""
    items: list[T]
    total: int
    pagina: int
    tamano: int
    total_paginas: int
