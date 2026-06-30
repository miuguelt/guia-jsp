from sqlalchemy import Column, Integer, String, Boolean, DateTime, text
from database import Base


class RolDB(Base):
    __tablename__ = "roles"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(50), unique=True, nullable=False)
    descripcion = Column(String(200), nullable=True)
    estado = Column(Boolean, default=True)
    fecha_creacion = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
