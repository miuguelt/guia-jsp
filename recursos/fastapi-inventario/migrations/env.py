"""Alembic environment configuration.
Equivalente a Flyway/Liquibase en Java.

Uso:
    alembic revision --autogenerate -m "descripcion"
    alembic upgrade head
    alembic downgrade -1
"""
import sys
from os.path import abspath, dirname, join

# Agregar el directorio raíz al path para importar modelos
sys.path.insert(0, join(dirname(dirname(abspath(__file__)))))

from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context

from config import settings
from database import Base

# Importar todos los modelos para que autogenerate los detecte
import models.producto
import models.rol
import models.usuario

config = context.config
config.set_main_option("sqlalchemy.url", settings.database_url)

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata


def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(url=url, target_metadata=target_metadata, literal_binds=True)
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
