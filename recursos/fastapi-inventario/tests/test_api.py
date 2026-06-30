"""
Pruebas automatizadas para la API FastAPI.
Equivalente a las pruebas unitarias en JSP (JUnit).

Usa SQLite en memoria para evitar dependencia de PostgreSQL.

Ejecutar:
    pytest tests/ -v
    pytest tests/test_api.py -v --cov=.
"""
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from database import Base, get_db
from main import app

SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.drop_all(bind=engine)
Base.metadata.create_all(bind=engine)

def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["database"] == "conectada"
    assert data["auth"] == "JWT habilitado"


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "mensaje" in data
    assert "version" in data


def test_login_credenciales_invalidas():
    response = client.post("/api/auth/login", json={
        "username": "usuario_inexistente",
        "password": "wrong",
    })
    assert response.status_code == 401


def test_register_datos_invalidos():
    response = client.post("/api/auth/register", json={
        "username": "test",
        "password": "123456",
        "nombre_completo": "Test",
        "email": "email-invalido",
        "rol_id": 2,
    })
    assert response.status_code == 422


def test_listar_productos():
    response = client.get("/api/productos/")
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert "total" in data
    assert "pagina" in data
    assert "tamano" in data
    assert "total_paginas" in data


def test_listar_productos_con_paginacion():
    response = client.get("/api/productos/?pagina=1&tamano=5")
    assert response.status_code == 200
    data = response.json()
    assert data["pagina"] == 1
    assert data["tamano"] == 5


def test_obtener_producto_no_existe():
    response = client.get("/api/productos/99999")
    assert response.status_code == 404


def test_ruta_no_existe():
    response = client.get("/api/ruta-inexistente")
    assert response.status_code == 404


def test_docs_disponible():
    response = client.get("/docs")
    assert response.status_code == 200
    assert "swagger" in response.text.lower() or "Swagger UI" in response.text
