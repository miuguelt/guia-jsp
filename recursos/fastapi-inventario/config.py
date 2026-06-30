# =========================================================================
# Configuración centralizada usando pydantic-settings
# Lee de variables de entorno o archivo .env
# =========================================================================
# Uso: from config import settings
#       settings.DATABASE_URL
#       settings.SECRET_KEY
# =========================================================================
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # PostgreSQL
    database_url: str = "postgresql://postgres:postgres@localhost:5432/inventario_db"

    # JWT
    secret_key: str = "sena-adso-jwt-secret-key-2026-cambiar-en-produccion"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    # Servidor
    host: str = "0.0.0.0"
    port: int = 8000
    reload: bool = True

    # CORS
    cors_origins: str = "http://localhost:5173,http://localhost:3000"

    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",")]

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
