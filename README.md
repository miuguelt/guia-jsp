# Guía de Aprendizaje - Full Stack: JSP + MVC → FastAPI + React → Flutter

## SENA - Análisis y Desarrollo de Software (ADSO)

Este repositorio contiene una **Guía de Aprendizaje completa** que cubre todo el stack de desarrollo web y móvil:
1. **Backend clásico**: JSP (JavaServer Pages) con patrón MVC, JDK 21, Jakarta EE 10 y PostgreSQL
2. **API moderna**: FastAPI con Python 3.10+, SQLAlchemy, Pydantic y JWT
3. **Frontend moderno**: React 19 con Vite, AuthContext, JWT y Axios
4. **App móvil multiplataforma**: Flutter 3.x + Dart con OpenAPI, Riverpod, GoRouter y microservicios

Toda la guía incluye instrucciones paralelas para **🐳 Docker** (producción, reproducible) y **🪟 Windows Nativo** (desarrollo local, debugging rápido).

---

## 📚 Contenido del Repositorio

### 🌐 Página Web Interactiva
- **`web/`** - Página web profesional e interactiva con toda la guía de aprendizaje
  - **`web/index.html`** - Página principal JSP + MVC + FastAPI + React
  - **`web/flutter-guide.html`** - Guía completa de Flutter + OpenAPI + Microservicios (1,500+ líneas)
  - **`web/simuladores.html`** - Simuladores interactivos de MVC, CRUD y comparador JDBC vs ORM
  - **`web/css/styles.css`** - Estilos profesionales con diseño moderno y responsive
  - **`web/js/main.js`** - JavaScript para interactividad, tabs, copy-to-clipboard y más
  - **`web/img/`** - Diagramas SVG (arquitectura MVC, flujo HTTP, JDBC vs ORM)
  - **`web/img/flutter/`** - Diagramas SVG de Flutter (arquitectura, API flow, microservicios, widgets)
  
**Secciones de la guía web:**
1. Identificación oficial SENA
2. Presentación con objetivos de aprendizaje
3. Reflexión inicial (caso código espagueti)
4. Fundamentos teóricos (MVC, JSP, Jakarta EE, JDBC, Records)
5. **Configuración de PostgreSQL** (paso a paso con BD existente)
6. **ORM: JPA/Hibernate vs JDBC** (con analogía a Flask + SQLAlchemy)
7. **Simuladores interactivos** (flujo MVC, CRUD, comparador)
8. Tutorial paso a paso (8 pasos)
9. Ejercicios de transferencia (3 niveles)
10. **API REST con FastAPI** (Python, SQLAlchemy, Pydantic, CRUD endpoints)
11. **Frontend con React 19** (Vite, Axios, componentes, consumo de API)
12. **App movil con Flutter + OpenAPI** (guia completa en web/flutter-guide.html)
13. Despliegue con Docker
14. Evidencias con rubrica

## 🐳 vs 🪟 Docker vs Nativo Windows

Cada proyecto puede ejecutarse de dos formas:

| Aspecto | 🐳 Docker | 🪟 Nativo Windows |
|---------|-----------|-------------------|
| **PostgreSQL** | `docker compose up db` | Servicio Windows |
| **FastAPI** | Contenedor aislado | `uvicorn main:app --reload` |
| **React** | Build multi-stage + Nginx | `npm run dev` (hot reload) |
| **Comando** | `docker compose up -d` | `.\start-fullstack.ps1` |
| **Recarga** | Rebuild manual | --reload automático |
| **Aislamiento** | ✅ Completo | ❌ Dependencias locales |
| **Ideal para** | Producción / equipo | Desarrollo / aprendizaje |

### Inicio Rápido Nativo Windows
```powershell
.\start-fullstack.ps1          # Iniciar todo
.\start-fullstack.ps1 -Stop    # Detener todo
.\start-fullstack.ps1 -Status  # Ver estado
```

### Inicio Rápido Docker
```bash
docker compose -f docker-compose.fullstack.yml up -d
docker compose -f docker-compose.fullstack.yml down
```

**Para abrir la página web (guía interactiva):**
```bash
# Simplemente abre el archivo web/index.html en tu navegador
# O usa un servidor local:
cd web
python -m http.server 8000
# Luego visita: http://localhost:8000
```

### 📄 Documento Principal
- **`Guia_Aprendizaje_JSP_MVC.docx`** - Documento Word completo con la guía pedagógica (40+ páginas)

### 💻 Código Fuente Completo
- **`recursos/codigo-ejemplo/`** - Proyecto Maven funcional (Java) con:
  - **Modelo**: Records de JDK 21 (Rol, Usuario, Producto)
  - **DAO**: Clases de acceso a datos con JDBC (ConexionDB, RolDAO, UsuarioDAO, ProductoDAO)
  - **Controlador**: Servlets Jakarta EE (LoginServlet, ProductoServlet, UsuarioServlet)
  - **Vista**: Páginas JSP con JSTL (sin scriptlets)
  - **Utilidades**: PasswordUtil con BCrypt
- **`recursos/fastapi-inventario/`** - Proyecto FastAPI funcional (Python) con:
  - **Modelos SQLAlchemy**: Mapeo de tablas PostgreSQL
  - **Schemas Pydantic**: Validación de datos automática
  - **Routers FastAPI**: CRUD completo (GET, POST, PUT, DELETE)
  - **Documentación Swagger**: UI interactiva en /docs
- **`recursos/frontend-inventario/`** - Proyecto React 19 funcional con:
  - **Vite**: Build tool moderno y rápido
  - **Axios**: Cliente HTTP para consumir FastAPI
  - **React Router**: Navegación SPA
  - **Componentes**: Navbar, ProductoCard, ProductoLista, ProductoForm

- **`recursos/flutter-inventario/`** - Proyecto Flutter completo (31 archivos, 5,700+ líneas) con:
  - **Riverpod**: Manejo de estado reactivo y tipado
  - **GoRouter**: Navegación declarativa con rutas protegidas
  - **Dio**: Cliente HTTP con interceptors JWT y manejo de errores 401
  - **Clean Architecture**: UI / Providers / Services / DataSources
  - **OpenAPI Generator**: Cliente Dart generado desde especificación OpenAPI
  - **Docker**: Multi-stage build para web (Flutter + Nginx, ~20MB)
  - **Tests**: Suite completa con Mockito (50+ tests)

### 🗄️ Base de Datos
- **`recursos/sql/inventario_db.sql`** - Script PostgreSQL completo con:
  - 3 tablas: roles, usuarios, productos
  - Datos de prueba
  - Índices y vistas
  - Triggers para auditoría automática

### 🐳 Despliegue
- **`recursos/docker/Dockerfile`** - Imagen Docker con Tomcat 10.1 + JDK 21
- **`generar_guia.py`** - Script Python para regenerar el documento DOCX

### 🧠 Integración DevBrain
- **`start-windows.ps1`** - Script de inicio nativo Windows para DevBrain Dashboard
- **`.devbrain/`** - Scripts de sesión, checkpoint e integridad
- Registrado en DevBrain como proyecto **☕ Guía JSP + MVC** (puerto 8024)

---

## 🧠 DevBrain Dashboard

Este proyecto está integrado con **DevBrain Dashboard**. Para iniciar el sitio web desde el dashboard:

```powershell
# Desde DevBrain Dashboard
# Buscar "Guía JSP + MVC" y clic en Start

# O manualmente:
.\start-windows.ps1          # Iniciar servidor guía web (puerto 8024)
.\start-flutter.ps1          # Iniciar microservicios + Flutter web
.\start-windows.ps1 -Status  # Ver estado
.\start-windows.ps1 -Stop    # Detener
```

El sitio web estará disponible en **http://localhost:8024**

### Scripts DevBrain incluidos:
- `.devbrain/session-start.ps1` - Protocolo de inicio de sesión
- `.devbrain/session-end.ps1` - Protocolo de cierre de sesión
- `.devbrain/checkpoint.ps1` - Guardar checkpoint
- `.devbrain/integrity-check.ps1` - Verificar integridad de archivos

---

## 🚀 Inicio Rápido

### Requisitos Previos
- JDK 21 o superior
- Apache Maven 3.9+
- PostgreSQL 12+
- Apache Tomcat 10.1.x
- Docker (opcional, para despliegue)

### 1. Configurar Base de Datos
```bash
# Crear base de datos
psql -U postgres -c "CREATE DATABASE inventario_db;"

# Ejecutar script SQL
psql -U postgres -d inventario_db -f recursos/sql/inventario_db.sql
```

### 2. Configurar Proyecto
```bash
# Navegar al directorio del proyecto
cd recursos/codigo-ejemplo

# Editar configuración de BD (si es necesario)
# Editar: src/main/resources/db.properties

# Compilar y empaquetar
mvn clean package
```

### 3. Desplegar en Tomcat
```bash
# Copiar WAR a Tomcat
copy target\inventario-mvc-1.0.war C:\apache-tomcat-10.1.x\webapps\

# Iniciar Tomcat
C:\apache-tomcat-10.1.x\bin\startup.bat

# Acceder a la aplicación
# http://localhost:8080/inventario-mvc-1.0/
```

### 4. Usuarios de Prueba
| Usuario | Contraseña | Rol |
|---------|------------|-----|
| admin | admin123 | Administrador |
| cliente1 | admin123 | Cliente |
| invitado | admin123 | Invitado |

---

## 🐳 Despliegue con Docker

### Construir Imagen
```bash
cd recursos/codigo-ejemplo
docker build -t inventario-mvc:1.0 -f ../docker/Dockerfile .
```

### Ejecutar Contenedor
```bash
docker run -d -p 8080:8080 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_NAME=inventario_db \
  -e DB_USER=postgres \
  -e DB_PASSWORD=tu_password \
  --name inventario-app \
  inventario-mvc:1.0
```

---

## 📖 Estructura del Proyecto

```
guia-jsp/
├── Guia_Aprendizaje_JSP_MVC.docx    # Documento principal
├── generar_guia.py                   # Script generador
├── README.md                         # Este archivo
└── recursos/
    ├── sql/
    │   └── inventario_db.sql        # Script PostgreSQL
    ├── docker/
    │   └── Dockerfile               # Configuración Docker
    ├── codigo-ejemplo/              # Proyecto JSP + MVC (Java)
    │   ├── pom.xml                  # Configuración Maven
    │   └── src/main/
    │       ├── java/com/sena/inventario/
    │       │   ├── modelo/          # Records (Rol, Usuario, Producto)
    │       │   ├── dao/             # Clases DAO con JDBC
    │       │   ├── controlador/     # Servlets Jakarta EE
    │       │   └── util/            # Utilidades (PasswordUtil)
    │       ├── resources/
    │       │   └── db.properties    # Configuración BD
    │       └── webapp/
    │           ├── WEB-INF/web.xml  # Descriptor de despliegue
    │           ├── productos/       # Vistas JSP de productos
    │           ├── usuarios/        # Vistas JSP de usuarios
    │           ├── css/estilo.css   # Estilos CSS
    │           ├── index.jsp        # Página principal
    │           └── login.jsp        # Formulario de login
    ├── fastapi-inventario/          # Proyecto FastAPI (Python)
    │   ├── main.py                  # Punto de entrada
    │   ├── database.py              # Conexión SQLAlchemy
    │   ├── requirements.txt         # Dependencias Python
    │   ├── models/
    │   │   └── producto.py          # Modelo SQLAlchemy
    │   ├── schemas/
    │   │   └── producto.py          # Esquema Pydantic
    │   └── routers/
    │       └── producto.py          # CRUD endpoints
    └── frontend-inventario/         # Proyecto React (JavaScript)
        ├── package.json             # Dependencias Node
        ├── vite.config.js           # Configuración Vite
        ├── index.html               # Entry point HTML
        └── src/
            ├── main.jsx             # Punto de entrada React
            ├── App.jsx              # Componente raíz + rutas
            ├── App.css              # Estilos globales
            ├── services/
            │   └── api.js           # Cliente Axios para FastAPI
            └── components/
                ├── Navbar.jsx       # Barra de navegación
                ├── ProductoCard.jsx # Tarjeta de producto
                ├── ProductoLista.jsx# Lista de productos
                └── ProductoForm.jsx # Formulario crear/editar
```

---

## 🎯 Competencias Desarrolladas

### Competencia Técnica
- Desarrollo de aplicaciones web con Jakarta EE 10
- Implementación del patrón MVC
- Uso de JDBC para acceso a bases de datos
- Programación con JDK 21 (records, pattern matching)
- Creación de páginas JSP con JSTL
- Despliegue con Docker

### Competencias Metodológicas
- Aplicación de buenas prácticas de POO
- Separación de responsabilidades
- Prevención de inyecciones SQL
- Gestión de sesiones y autenticación
- Documentación de código

---

## 📝 Estructura de la Guía

El documento Word contiene las siguientes secciones:

1. **Identificación de la Guía** - Información oficial del programa
2. **Presentación** - Introducción motivacional al MVC y tecnologías
3. **Actividades de Aprendizaje**
   - 3.1 Reflexión Inicial - Caso de estudio "código espagueti"
   - 3.2 Apropiación del Conocimiento - Tutorial completo paso a paso
   - 3.3 Transferencia del Conocimiento - 3 ejercicios retadores
4. **Despliegue en Coolify** - Dockerización y despliegue moderno
5. **Evidencias de Aprendizaje** - Rúbrica de evaluación completa
6. **Bibliografía** - Referencias y recursos adicionales

---

## 🔧 Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| JDK | 21 (LTS) | Compilación y ejecución |
| Jakarta EE | 10 | Estándar empresarial |
| Jakarta Servlet | 6.0 | Manejo de peticiones HTTP |
| Jakarta JSTL | 3.0 | Etiquetas en JSP |
| PostgreSQL | 12+ | Base de datos relacional |
| Apache Maven | 3.9+ | Gestión de dependencias |
| Apache Tomcat | 10.1.x | Servidor de aplicaciones |
| Docker | 24+ | Contenedores |
| BCrypt | 0.10.2 | Encriptación de contraseñas |
| Python | 3.10+ | Backend moderno con FastAPI |
| FastAPI | 0.115+ | Framework REST para APIs |
| SQLAlchemy | 2.0+ | ORM para Python |
| Pydantic | 2.9+ | Validación de datos |
| Node.js | 18+ | Entorno de ejecución frontend |
| React | 19 | Biblioteca de UI moderna |
| Vite | 5.4+ | Build tool frontend |
| Axios | 1.7+ | Cliente HTTP |
| Flutter | 3.x | Framework UI multiplataforma |
| Dart | 3.x | Lenguaje de programación moderno |
| Riverpod | 2.x | Manejo de estado reactivo |
| GoRouter | 14.x | Navegación declarativa |
| Dio | 5.x | Cliente HTTP con interceptors |
| OpenAPI Generator | 7.x | Generación de clientes desde especificación OpenAPI |

---

## 📊 Funcionalidades Implementadas

### CRUD Completo para 3 Entidades
✅ **Roles**: Crear, Leer, Actualizar, Eliminar  
✅ **Usuarios**: Crear, Leer, Actualizar, Eliminar  
✅ **Productos**: Crear, Leer, Actualizar, Eliminar  

### Características Adicionales
- Autenticación con sesiones
- Encriptación de contraseñas con BCrypt
- Validación de formularios
- Búsqueda por categoría
- Indicadores visuales de stock bajo
- Diseño responsive con CSS
- Manejo de errores

---

## 🎓 Ejercicios de Transferencia

La guía incluye 3 ejercicios retadores:

1. **Buscador de Productos** - Implementar búsqueda por nombre y rango de precios
2. **Tabla Categorías** - Crear nueva entidad con relación 1:N a Productos
3. **Sistema de Auditoría** - Implementar registro de operaciones con filtros

---

## 📞 Soporte

Para dudas o consultas sobre esta guía:
- **Instructor ADSO**: [Contactar al instructor]
- **Ficha**: [Número de ficha]
- **Centro**: [Centro de formación]

---

## 📄 Licencia

Este material es propiedad del SENA y está destinado para uso educativo en el programa de Análisis y Desarrollo de Software.

---

## 🔄 Historial de Versiones

- **v1.0** (Junio 2026) - Versión inicial con JDK 21, Jakarta EE 10, PostgreSQL
- **v2.0** (Junio 2026) - Nuevas guías de FastAPI + React 19 con código + resultados visuales
- **v2.1** (Junio 2026) - Nueva guía Flutter + OpenAPI + Microservicios con proyecto completo (31 archivos, 5,700+ líneas)

---

**¡Éxitos en tu aprendizaje del desarrollo web Full Stack!** 🚀

> De JSP + MVC a FastAPI + React: el mismo patrón, tecnologías modernas.

---

## 📦 Descargas — Proyectos Listos para Ejecutar

Cada proyecto de esta guía está disponible como descarga directa. Solo extrae el ZIP y ejecuta:

| Proyecto | Descripción | Comando para ejecutar | Descargar |
|----------|-------------|----------------------|-----------|
| **JSP+MVC** | Sistema de inventario con Jakarta EE 10, JDK 21, PostgreSQL | `mvn clean package cargo:run` | [codigo-ejemplo.zip](web/downloads/codigo-ejemplo.zip) (32 KB) |
| **FastAPI** | API REST con SQLAlchemy, Pydantic, JWT, Alembic | `pip install -r requirements.txt && uvicorn main:app --reload` | [fastapi-inventario.zip](web/downloads/fastapi-inventario.zip) (39 KB) |
| **React 19** | Frontend SPA con Vite, Axios, React Router, AuthContext | `npm install && npm run dev` | [frontend-inventario.zip](web/downloads/frontend-inventario.zip) (32 KB) |
| **Flutter** | App móvil con Riverpod, GoRouter, Dio, OpenAPI | `flutter pub get && flutter run` | [flutter-inventario.zip](web/downloads/flutter-inventario.zip) (59 KB) |
| **SQL** | Script de base de datos PostgreSQL (roles, usuarios, productos) | `psql -U postgres -d inventario_db -f inventario_db.sql` | [inventario-db-sql.zip](web/downloads/inventario-db-sql.zip) (2 KB) |

> Todos los proyectos incluyen `.env` o `db.properties` con valores por defecto para desarrollo local. Ajusta las credenciales según tu configuración.

---

## Navegacion entre Guias - Ruta de Aprendizaje ADSO

| Orden | Guia | Puerto | Fase ADSO |
|-------|------|--------|-----------|
| 1 | [Guia Flask](../Guia-Flask) | 5000 | 4 - Ejecucion |
| 2 | [Guia FastAPI](../Guia%20FastApi) | 8025 | 4 - Ejecucion |
| **3** | **Guia JSP + Flutter (aqui)** | **8024** | **4 - Ejecucion** |
| 4 | [Guia React](../Guia%20React) | 8030 | 4 - Ejecucion |
| 5 | [Guia Testing & QA](../Guia%20Testing) | 8035 | 5 - Evaluacion |

**Anterior:** [Guia FastAPI](../Guia%20FastApi) - Microservicios REST modernos.
**Siguiente:** [Guia React](../Guia%20React) - Frontend SPA moderno.

Esta guia ya incluye secciones 3.5 (FastAPI) y 3.6 (React) dentro de su DOCX, demostrando la sinergia entre guias.
