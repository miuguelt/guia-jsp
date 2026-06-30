# 📦 App Flutter de Inventario - SENA ADSO

**Sistema de gestión de inventario multiplataforma** desarrollado con Flutter como parte del programa **Análisis y Desarrollo de Sistemas de Información (ADSO) — ficha 228123**.

Esta aplicación consume microservicios REST construidos con FastAPI y expone una interfaz moderna e intuitiva para administrar productos, usuarios y autenticación mediante JWT.

---

## 📋 Requisitos previos

| Herramienta | Versión | Propósito |
|---|---|---|
| **Flutter SDK** | `>=3.0.0` | Framework de UI multiplataforma |
| **Dart SDK** | `>=3.0.0 <4.0.0` | Lenguaje de programación |
| **VS Code** o **Android Studio** | — | Editor/IDE con plugins de Flutter y Dart |
| **Docker Desktop** | >=4.x | Contenerización de microservicios backend |

### Verificar instalación

```bash
flutter --version
dart --version
docker --version
```

---

## 📁 Estructura del proyecto

```
recursos/flutter-inventario/
├── lib/
│   ├── main.dart                      # Punto de entrada (ProviderScope)
│   ├── app.dart                       # Widget raíz + GoRouter
│   ├── core/
│   │   ├── constants.dart             # URL base, claves SharedPrefs
│   │   ├── theme.dart                 # Tema Material 3 (colores SENA)
│   │   └── network/
│   │       ├── api_client.dart        # Cliente Dio + interceptores
│   │       └── api_exceptions.dart    # ApiException personalizada
│   ├── models/
│   │   ├── auth_response.dart         # Respuesta login (token + usuario)
│   │   ├── producto.dart              # Modelo Producto + PaginatedResponse
│   │   └── usuario.dart               # Modelos Usuario y Rol
│   ├── services/
│   │   ├── auth_service.dart          # Login, register, getProfile, roles
│   │   ├── producto_service.dart      # CRUD productos (API)
│   │   └── usuario_service.dart       # CRUD usuarios (solo Admin)
│   ├── providers/
│   │   ├── auth_provider.dart         # StateNotifier de autenticación
│   │   ├── productos_provider.dart    # AsyncNotifier de productos
│   │   └── usuarios_provider.dart     # AsyncNotifier de usuarios
│   └── screens/
│       ├── login_screen.dart          # Formulario de inicio de sesión
│       ├── register_screen.dart       # Registro con selección de rol
│       ├── home_screen.dart           # Dashboard + Drawer navegación
│       └── productos/
│           ├── productos_list_screen.dart  # Lista con búsqueda local
│           ├── producto_form_screen.dart   # Crear/editar producto
│           └── producto_detail_screen.dart # Detalle del producto
├── pubspec.yaml                       # Dependencias del proyecto
├── analysis_options.yaml              # Reglas de análisis Dart
└── README.md                          # Esta guía 🎯
```

---

## 🚀 Inicio rápido

### 1. Clonar o ubicarse en el proyecto

```bash
cd guia-jsp/recursos/flutter-inventario
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Iniciar microservicios (PostgreSQL + FastAPI)

Desde la **raíz del proyecto `guia-jsp/`**, ejecuta:

```bash
docker compose -f docker-compose.microservices.yml up -d
```

Esto levanta:

| Servicio | Puerto | Descripción |
|---|---|---|
| `db` | `5432` | PostgreSQL 16 |
| `auth-service` | `8001` | Login, registro, JWT |
| `products-service` | `8002` | CRUD de productos |
| `users-service` | `8003` | CRUD de usuarios |
| `frontend` (React) | `80` | SPA en React (opcional) |
| **API Gateway (NGINX)** | **`8000`** | Unifica los servicios bajo `/api` |

> ⏳ Espera ~15 segundos a que PostgreSQL esté listo y los servicios se registren.

### 4. Verificar que el backend responde

```bash
curl -s http://localhost:8000/api/docs | head -5
```

Si ves el Swagger UI de FastAPI, ¡está funcionando! ✅

### 5. Configurar `API_BASE_URL` (solo si es necesario)

Edita `lib/core/constants.dart`:

```dart
static const String apiBaseUrl = 'http://localhost:8000/api';
```

| Escenario | Valor |
|---|---|
| Desarrollo local (web) | `http://localhost:8000/api` |
| Android Emulator | `http://10.0.2.2:8000/api` |
| Dispositivo físico (misma red) | `http://<TU_IP>:8000/api` |
| Producción | `https://tudominio.com/api` |

### 6. Ejecutar la app

```bash
flutter run -d chrome
```

Esto abre la app en el navegador. ¡Regístrate o inicia sesión con las credenciales que crees! 🎉

---

## 🏗️ Arquitectura

La app sigue una arquitectura **Clean Architecture** simplificada en tres capas:

```
┌─────────────────────────────────────────────────────────────┐
│                    UI LAYER (Widgets/Screens)                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │  LoginScreen  │  │  HomeScreen   │  │ ProductosScreen  │   │
│  │ RegisterScreen│  │  Drawer       │  │ ProductoForm     │   │
│  └──────┬───────┘  └──────┬───────┘  └───────┬──────────┘   │
│         │                 │                   │              │
├─────────┼─────────────────┼───────────────────┼──────────────┤
│         ▼                 ▼                   ▼              │
│              STATE MANAGEMENT (Riverpod)                     │
│  ┌──────────────────┐  ┌───────────────────────────────┐     │
│  │  authProvider     │  │  productosProvider            │     │
│  │  (StateNotifier)  │  │  usuariosProvider             │     │
│  │                   │  │  (AsyncNotifier)              │     │
│  └──────┬───────────┘  └──────────┬────────────────────┘     │
│         │                         │                          │
├─────────┼─────────────────────────┼──────────────────────────┤
│         ▼                         ▼                          │
│                SERVICE LAYER                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │  AuthService   │  │ProductoService│  │  UsuarioService  │   │
│  └──────┬───────┘  └──────┬───────┘  └───────┬──────────┘   │
│         │                 │                   │              │
├─────────┼─────────────────┼───────────────────┼──────────────┤
│         ▼                 ▼                   ▼              │
│                DATA SOURCES (Dio / ApiClient)                │
│  ┌──────────────────────────────────────────────────────┐    │
│  │  ApiClient (singleton Dio)                          │    │
│  │  ├─ JWT Interceptor  →  Authorization: Bearer      │    │
│  │  ├─ Error Interceptor →  ApiException               │    │
│  │  └─ Log Interceptor  →  Depuración en consola       │    │
│  └──────────────────────┬───────────────────────────────┘    │
│                         │                                    │
│                         ▼                                    │
│              🌐 FastAPI Microservices                        │
│         (auth:8001 / products:8002 / users:8003)             │
└─────────────────────────────────────────────────────────────┘
```

### 🎨 UI Layer

Widgets de Flutter con Material 3. Cada pantalla es un `ConsumerStatefulWidget` o `ConsumerWidget` que observa providers de Riverpod.

### ⚛️ State Management (Riverpod)

- **`AuthNotifier`** (`StateNotifier<AuthState>`): maneja login, logout, registro y persistencia del token.
- **`ProductosNotifier`** (`AsyncNotifier<List<Producto>>`): CRUD de productos con estado `AsyncValue`.
- **`UsuariosNotifier`** (`AsyncNotifier<List<Usuario>>`): CRUD de usuarios, solo visible para administradores.

### 🔧 Service Layer

Clases que encapsulan las llamadas HTTP con `Dio`. Cada servicio mapea un microservicio:

| Clase | Endpoints base |
|---|---|
| `AuthService` | `/auth/login`, `/auth/register`, `/auth/me`, `/roles/` |
| `ProductoService` | `/productos/` (GET, POST, PUT, DELETE) |
| `UsuarioService` | `/usuarios/` (GET, PUT), `/auth/register` (POST) |

### 🌐 Data Sources

`ApiClient` crea una instancia singleton de `Dio` con tres interceptores:
1. **JWT Interceptor** — Inyecta `Authorization: Bearer <token>` automáticamente.
2. **Error Interceptor** — Convierte errores HTTP en `ApiException` y limpia el token si hay 401.
3. **Log Interceptor** — Imprime peticiones/respuestas en consola para depuración.

---

## 🌍 Consumo de APIs con OpenAPI

### ApiClient + Dio Interceptors

La comunicación con el backend se centraliza en `lib/core/network/api_client.dart`:

```dart
Dio createApiClient() {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,  // http://localhost:8000/api
    connectTimeout: Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  // Interceptor 1: JWT automático
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await _getTokenFromPrefs();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    },
  ));

  // Interceptor 2: Manejo de errores (401 → limpiar sesión)
  dio.interceptors.add(InterceptorsWrapper(
    onError: (error, handler) {
      if (error.response?.statusCode == 401) _clearSession();
      handler.reject(DioException(..., error: ApiException(message)));
    },
  ));

  return dio;
}
```

### OpenAPI Generator (nota técnica)

Los microservicios FastAPI exponen su especificación OpenAPI en `/api/openapi.json`. Para proyectos más grandes, puedes generar el cliente Dart automáticamente con:

```bash
# Instalar el generador
dart pub global activate openapi_generator

# Generar cliente desde la especificación
openapi-generator generate -i http://localhost:8000/api/openapi.json \
  -g dart-dio -o lib/generated/api
```

Este proyecto implementa los servicios **manualmente** para fines educativos, mostrando cómo se mapea cada endpoint a un método Dart.

### Capa de Servicios

Cada servicio recibe la instancia de `Dio` vía Riverpod y mapea los endpoints REST a métodos tipados:

```dart
// Ejemplo: ProductoService.getAll()
Future<PaginatedResponse<Producto>> getAll({int page = 1, int size = 20}) async {
  final response = await _dio.get('/productos/', queryParameters: {
    'pagina': page, 'tamano': size,
  });
  return PaginatedResponse.fromJson(
    response.data as Map<String, dynamic>,
    Producto.fromJson,
  );
}
```

---

## 🧭 Rutas y navegación

Se usa **GoRouter** con enrutamiento declarativo y protección de rutas basada en el estado de autenticación.

### Definición de rutas (`lib/app.dart`)

```dart
GoRouter(
  redirect: (context, state) {
    final isAuth = authState.isAuthenticated;
    final location = state.matchedLocation;

    if (!isAuth && location != '/login' && location != '/register')
      return '/login';
    if (isAuth && (location == '/login' || location == '/register'))
      return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login',    builder: (_, __) => LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => RegisterScreen()),
    GoRoute(path: '/',         builder: (_, __) => HomeScreen()),
    GoRoute(path: '/productos', ...
      routes: [
        GoRoute(path: 'nuevo',      ... ProductoFormScreen()),
        GoRoute(path: ':id',        ... ProductoDetailScreen()),
        GoRoute(path: ':id/editar', ... ProductoFormScreen()),
      ],
    ),
    GoRoute(path: '/usuarios', ...
      routes: [
        GoRoute(path: 'nuevo',      ... UsuarioFormScreen()),
        GoRoute(path: ':id/editar', ... UsuarioFormScreen()),
      ],
    ),
  ],
);
```

### Mapa de rutas

| Ruta | Pantalla | Protegida |
|---|---|---|
| `/login` | LoginScreen | ❌ (pública) |
| `/register` | RegisterScreen | ❌ (pública) |
| `/` | HomeScreen (Dashboard) | ✅ |
| `/productos` | ProductosListScreen | ✅ |
| `/productos/nuevo` | ProductoFormScreen (crear) | ✅ |
| `/productos/:id` | ProductoDetailScreen | ✅ |
| `/productos/:id/editar` | ProductoFormScreen (editar) | ✅ |
| `/usuarios` | UsuariosListScreen | ✅ (rol Admin) |
| `/usuarios/nuevo` | UsuarioFormScreen (crear) | ✅ (rol Admin) |
| `/usuarios/:id/editar` | UsuarioFormScreen (editar) | ✅ (rol Admin) |

---

## 🔐 Autenticación

### Flujo de login

```
Usuario                  App Flutter                  FastAPI Auth Service
  │                         │                              │
  │  Ingresa credenciales   │                              │
  ├────────────────────────▶│                              │
  │                         │  POST /auth/login            │
  │                         ├─────────────────────────────▶│
  │                         │                              │
  │                         │  ◀───────────────────────────┤
  │                         │  { access_token, usuario }   │
  │                         │                              │
  │                         │  Guarda en SharedPreferences │
  │                         │  ┌────────────────────┐      │
  │                         │  │ token → auth_token │      │
  │                         │  │ user  → auth_user  │      │
  │                         │  └────────────────────┘      │
  │                         │                              │
  │  Redirige a Dashboard   │                              │
  │◀────────────────────────│                              │
```

### Persistencia del token

- El token JWT y los datos del usuario se guardan en **SharedPreferences** usando las claves definidas en `AppConstants` (`auth_token`, `auth_user`).
- Al iniciar la app, `AuthNotifier.checkAuth()` restaura la sesión desde SharedPreferences y valida el token consultando `GET /auth/me`.
- Si el token expiró o es inválido, se limpia el almacenamiento y se redirige al login.

### Roles del sistema

| Rol | Acceso |
|---|---|
| **Administrador** (ID: 1) | CRUD completo de productos y usuarios |
| **Auxiliar de Bodega** (ID: 2) | CRUD de productos |
| **Consultor** (ID: 3) | Solo lectura de productos |

### Protección en el frontend

- El router (`GoRouter`) redirige a `/login` si el usuario no está autenticado.
- Las opciones de administración de usuarios solo se muestran si `authState.isAdmin` es `true`.
- El backend también valida el JWT y los permisos en cada petición (defensa en profundidad).

---

## 🐳 Despliegue con Docker

### Build como app web

```bash
# Construir los assets de Flutter Web
flutter build web --release

# Los archivos estáticos se generan en: build/web/
```

Luego puedes servir los archivos con cualquier servidor HTTP (NGINX, Apache, etc.) o incluirlos en un contenedor Docker:

```dockerfile
FROM nginx:alpine
COPY build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Despliegue completo con Docker Compose

El archivo `docker-compose.microservices.yml` ya incluye el frontend React en el puerto 80. Para desplegar la versión Flutter, reemplaza el servicio `frontend`:

```yaml
frontend-flutter:
  build:
    context: ./recursos/flutter-inventario
    dockerfile: Dockerfile
  ports:
    - "80:80"
  depends_on:
    - auth-service
    - products-service
    - users-service
```

---

## 🔧 Solución de problemas

### ❌ CORS errors en la consola del navegador

**Causa:** El navegador bloquea peticiones a un origen diferente.

**Solución:** Los microservicios FastAPI ya incluyen CORS middleware. Verifica que `docker-compose.microservices.yml` tenga configurado `CORS_ORIGINS=*` o la URL de tu frontend.

### ❌ Connection refused / ECONNREFUSED

**Causa:** Los microservicios no están iniciados.

**Solución:**

```bash
# Verificar el estado de los contenedores
docker compose -f docker-compose.microservices.yml ps

# Ver logs del API Gateway
docker compose -f docker-compose.microservices.yml logs auth-service

# Reinciar servicios si es necesario
docker compose -f docker-compose.microservices.yml down
docker compose -f docker-compose.microservices.yml up -d
```

### ❌ Android Emulator — no se conecta al backend

**Causa:** En el emulador de Android, `localhost` apunta al emulador, no a tu máquina host.

**Solución:** Cambia `apiBaseUrl` en `lib/core/constants.dart`:

```dart
static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
```

`10.0.2.2` es la dirección especial del host desde el emulador de Android.

### ❌ Widget no se actualiza después de login

**Causa:** El router no refresca sus rutas automáticamente.

**Solución:** En `app.dart`, el `InventarioApp` escucha cambios en `authProvider` y llama a `router.refresh()` cuando cambia el estado de autenticación:

```dart
ref.listen<AuthState>(authProvider, (prev, next) {
  if (prev?.isAuthenticated != next.isAuthenticated) {
    router.refresh();
  }
});
```

### ❌ Error: "No se puede acceder al archivo pubspec.yaml"

**Causa:** No estás en el directorio correcto.

**Solución:** Asegúrate de ejecutar `flutter pub get` desde `recursos/flutter-inventario/`.

### ❌ Token inválido después de cambiar la clave secreta

**Causa:** Los tokens JWT emitidos con una clave `SECRET_KEY` anterior no son válidos después de reiniciar los servicios con una nueva clave.

**Solución:** Cierra sesión manualmente (borra el almacenamiento local del navegador) o implementa un mecanismo de refresh token.

---

## 🎓 Créditos

| Rol | Nombre |
|---|---|
| **Programa** | Análisis y Desarrollo de Sistemas de Información — ADSO |
| **Ficha** | 228123 |
| **Entidad** | Servicio Nacional de Aprendizaje — **SENA** 🇨🇴 |
| **Instructores** | Equipo de formación SENA ADSO |
| **Tecnologías** | Flutter, Dart, Riverpod, Dio, GoRouter, FastAPI, PostgreSQL, Docker |

---

<p align="center">
  <strong>SENA ADSO — Ficha 228123</strong><br>
  <em>"Aprendices formados con calidad, al servicio del país"</em><br>
  <img src="https://img.shields.io/badge/SENA-ADSO-00664A?style=flat-square&logo=flutter" alt="SENA ADSO">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Docker-✓-2496ED?style=flat-square&logo=docker" alt="Docker">
  <img src="https://img.shields.io/badge/FastAPI-✓-009688?style=flat-square&logo=fastapi" alt="FastAPI">
</p>
