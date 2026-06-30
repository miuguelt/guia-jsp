from sqlalchemy import Column, Integer, String, Numeric, Boolean, DateTime, ForeignKey, text
from sqlalchemy.orm import relationship
from database import Base


class ProductoDB(Base):
    __tablename__ = "productos"

    id = Column(Integer, primary_key=True, index=True)
    codigo = Column(String(50), unique=True, nullable=False)
    nombre = Column(String(100), nullable=False)
    descripcion = Column(String(500), nullable=True)
    precio = Column(Numeric(10, 2), nullable=False)
    stock = Column(Integer, default=0)
    categoria = Column(String(50), nullable=True)
    estado = Column(Boolean, default=True)
    usuario_creador_id = Column(Integer, ForeignKey("usuarios.id"), nullable=True)
    fecha_registro = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

    # Relación: un usuario puede crear muchos productos
    creador = relationship("UsuarioDB", backref="productos_creados")
