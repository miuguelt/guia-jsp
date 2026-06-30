from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, text
from sqlalchemy.orm import relationship
from database import Base


class UsuarioDB(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    password = Column(String(255), nullable=False)
    nombre_completo = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    rol_id = Column(Integer, ForeignKey("roles.id"), nullable=False)
    estado = Column(Boolean, default=True)
    fecha_creacion = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

    # Relación: muchos usuarios pertenecen a un rol
    rol = relationship("RolDB", backref="usuarios")
