# Estandar Profesional de Codigo - Guia JSP + MVC

## Filosofia
Todo componente debe cubrir 4 estados: **loading**, **error**, **empty**, **data**.
Prohibido usar `alert()`, `confirm()`, `prompt()` del navegador.
Prohibido hardcodear credenciales o valores sensibles.
Cada tecnologia tiene sus patrones especificos (ver secciones abajo).

---

## 1. React (frontend-inventario)

### 1.1 Componentes de Lista
**Referencia:** `ProductoLista.jsx` (gold standard)

```jsx
// Template minimo obligatorio:
export default function Lista() {
  const [items, setItems] = useState([])
  const [cargando, setCargando] = useState(true)
  const [error, setError] = useState(null)
  const [filtro, setFiltro] = useState('')
  const [mensaje, setMensaje] = useState(null)

  // loading
  if (cargando) return <Spinner mensaje="Cargando..." />

  // error
  if (error) return <ErrorState mensaje={error} onReintentar={cargar} />

  // empty
  if (items.length === 0) return <EmptyState mensaje="No hay items" />

  // data
  return (
    <>
      {mensaje && <MensajeFlash ... />}
      <FiltroBusqueda ... />
      <Grid ... />
      <Paginacion ... />
    </>
  )
}
```

**Reglas:**
- NO usar `confirm()` ni `alert()` → usar componente `MensajeFlash` o modal
- Filtro local con `useState` + `filter()` para busqueda instantanea
- Paginacion con estado `pagina` y `totalPaginas`
- Mensajes de exito/error con auto-dismiss o boton de cerrar
- Cada item debe ser un componente separado (ej: `ProductoCard`)

### 1.2 Componentes de Formulario
**Referencia:** `ProductoForm.jsx` (gold standard)

```jsx
const [form, setForm] = useState({ campo: '' })
const [enviando, setEnviando] = useState(false)
const [error, setError] = useState(null)

// Bloquear boton durante envio
<button disabled={enviando}>
  {enviando ? 'Guardando...' : 'Guardar'}
</button>
```

**Reglas:**
- NO usar `alert()` para exito/error → usar estado `mensaje` o componente `MensajeFlash`
- `useParams()` para detectar modo edicion: `const esEdicion = Boolean(id)`
- `parseFloat`/`parseInt` al enviar, string en el estado del form
- Errores de API: `err.response?.data?.detail || 'Mensaje generico'`
- Label con `*` para campos obligatorios, `required` en input
- Boton Cancelar que navega hacia atras

### 1.3 Servicios API (api.js)
**Referencia:** `services/api.js`

- Cliente Axios con `baseURL` desde `import.meta.env.VITE_API_URL`
- Interceptor JWT: leer token de `localStorage`, agregar `Authorization: Bearer`
- Interceptor 401: limpiar storage y redirigir a `/login`
- Funciones agrupadas por dominio: `Auth API`, `Productos API`, `Usuarios API`
- Paginacion: parametros `pagina`, `tamano`, respuesta `{ items, total, pagina, tamano, total_paginas }`

### 1.4 Auth Context (AuthContext.jsx)
**Referencia:** `contexts/AuthContext.jsx`

- Proveer: `usuario`, `login`, `logout`, `cargando`, `isAuthenticated`, `isAdmin`
- Persistencia en `localStorage` con `access_token` y `usuario`
- `logout()`: limpiar storage + redirigir
- `useAuth()` con validacion: `if (!context) throw new Error(...)`

### 1.5 Layout y Routing (App.jsx)
**Referencia:** `App.jsx`, `ProtectedRoute.jsx`

- `ProtectedRoute` con 3 estados: cargando, no autenticado (redirect), no admin (denied)
- `adminOnly` prop para rutas de administrador
- `Navbar` auth-aware con condicionales `isAuthenticated` e `isAdmin`

### 1.6 CSS (App.css)
**Referencia:** `App.css`

- Usar unidades relativas, flexbox/grid, transiciones suaves
- Nombre de clases con prefijo del componente (`.producto-card`, `.producto-header`)
- Estados con clases: `.activo`, `.inactivo`, `.stock-bajo`, `.stock-normal`
- Responsive con `@media (max-width: 768px)` y `(max-width: 600px)`
- Animacion spinner con `@keyframes`

---

## 2. FastAPI (fastapi-inventario)

### 2.1 Estructura de Router
**Referencia:** `routers/producto.py`

```python
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional

logger = logging.getLogger("api.productos")
router = APIRouter(prefix="/api/productos", tags=["Productos"])

@router.get("/", response_model=PaginatedResponse)
async def listar(
    pagina: int = Query(1, ge=1),
    tamano: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db),
):
    ...
    return PaginatedResponse(items=..., total=..., pagina=pagina, ...)

@router.post("/", response_model=Modelo, status_code=status.HTTP_201_CREATED)
async def crear(payload: SchemaCreate, db: Session = Depends(get_db), usuario = Depends(obtener_usuario_actual)):
    ...
```

**Reglas:**
- `response_model` siempre definido
- Status codes explicitos: 201 para crear, 204 para eliminar
- Docstring con formato `METHOD /path — descripcion`
- Logging en cada operacion: `logger.info(f"Producto creado ID={id} por usuario={user}")`
- Paginacion con `pagina`/`tamano` via `Query(ge=1)`
- Validacion numerica en Query: `ge=1, le=100`
- Actualizar con `for key, value in payload.model_dump().items(): setattr(db_obj, key, value)`

### 2.2 Main app (main.py)
**Referencia:** `main.py`

- `lifespan` para crear tablas al iniciar
- `CORSMiddleware` con orígenes desde config
- Manejadores globales: `ValueError` → 400, `Exception` → 500 con timestamp
- Middleware HTTP para log de todas las peticiones con duracion
- Root endpoint con listado de endpoints disponible

### 2.3 Schemas (schemas/)
**Referencia:** `schemas/producto.py`

```python
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, Generic, TypeVar

T = TypeVar("T")

class BaseSchema(BaseModel):
    campo: str = Field(..., min_length=3, max_length=50)
    numerico: int = Field(default=0, ge=0)

class CreateSchema(BaseSchema):
    pass

class ResponseSchema(BaseSchema):
    id: int
    model_config = ConfigDict(from_attributes=True)

class PaginatedResponse(BaseModel, Generic[T]):
    items: list[T]
    total: int
    pagina: int
    tamano: int
    total_paginas: int
```

- `Field(..., min_length=..., max_length=...)` para validacion de strings
- `Field(..., gt=0, decimal_places=2)` para numeros
- `from_attributes=True` en ResponseSchema para ORM mode
- `Generic[T]` para respuestas paginadas reutilizables

### 2.4 Modelos SQLAlchemy (models/)
**Referencia:** `models/producto.py`

- `__tablename__` en plural
- `server_default=text("CURRENT_TIMESTAMP")` para fechas automaticas
- `relationship()` con `backref` para relaciones FK
- `nullable=True` en campos opcionales

---

## 3. Flutter (flutter-inventario)

### 3.1 Tema (core/theme.dart)
**Referencia:** `core/theme.dart`

- Clase estatica `AppTheme` con colores como constantes
- `lightTheme` getter con `ThemeData(useMaterial3: true, ...)`
- Paleta SENA: `#00664A` (verde primario), `#008C6E` (secundario)
- `AppBarTheme`, `ElevatedButtonTheme`, `CardTheme`, `InputDecorationTheme`, `FloatingActionButtonTheme`

### 3.2 API Client (core/network/api_client.dart)
**Referencia:** `core/network/api_client.dart`

- 3 interceptores obligatorios:
  1. **JWT Interceptor**: Lee token de SharedPreferences, inyecta `Authorization: Bearer`
  2. **Error Interceptor**: Convierte DioException → ApiException, limpia token en 401
  3. **Log Interceptor**: Debug con request/response body
- Provider: `final dioProvider = Provider<Dio>((ref) => createApiClient())`

### 3.3 Auth Provider
**Referencia:** `providers/auth_provider.dart`

- Estado inmutable con `copyWith()`
- `isAuthenticated` y `isAdmin` como computed getters
- Persistencia: `_saveSession()` y `_clearStorage()` en SharedPreferences
- `checkAuth()` al iniciar app para restaurar sesion

### 3.4 Pantallas
**Referencia:** `login_screen.dart`, `productos_list_screen.dart`

```dart
// Template minimo:
class MiScreen extends ConsumerStatefulWidget { ... }
class _MiScreenState extends ConsumerState<MiScreen> {
  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(miProvider);
    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, ...),
            Text('Error: $error'),
            ElevatedButton(onPressed: () => ref.read(miProvider.notifier).fetchAll(), child: Text('Reintentar')),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) return Center(child: Column(children: [Icon(...), Text('No hay items')]));
        return RefreshIndicator(
          onRefresh: () => ref.read(miProvider.notifier).fetchAll(),
          child: ListView.builder(...),
        );
      },
    );
  }
}
```

- `ConsumerStatefulWidget` para pantallas con estado local (busqueda, controladores)
- `ConsumerWidget` para widgets estaticos sin estado local
- `Form` con `GlobalKey<FormState>()` y validacion de campos
- `TextEditingController` con `dispose()`

### 3.5 Modelos
**Referencia:** `models/producto.dart`

```dart
class MiModelo {
  final int id;
  final String campo;
  final double precio;

  const MiModelo({required this.id, required this.campo, required this.precio});

  factory MiModelo.fromJson(Map<String, dynamic> json) => MiModelo(
    id: json['id'] as int,
    campo: json['campo'] as String,
    precio: (json['precio'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => { 'campo': campo, 'precio': precio };

  MiModelo copyWith({int? id, String? campo, double? precio}) => MiModelo(
    id: id ?? this.id,
    campo: campo ?? this.campo,
    precio: precio ?? this.precio,
  );
}
```

### 3.6 Servicios
**Referencia:** `services/producto_service.dart`

- Clase que recibe `Dio` en constructor
- Metodos con try/catch, re-lanzando como `ApiException`
- Parametros tipados y documentados

---

## 4. Java / JSP (codigo-ejemplo)

### 4.1 Modelos con Record (JDK 21+)
**Referencia:** `modelo/Producto.java`

```java
public record Producto(int id, String codigo, String nombre, BigDecimal precio, int stock) {
    public Producto(String codigo, String nombre, BigDecimal precio, int stock) {
        this(0, codigo, nombre, precio, stock, true, LocalDateTime.now(), null);
    }
}
```

- Usar `record` SIEMPRE para entidades (inmutables, compactas)
- Constructores adicionales para crear sin ID

### 4.2 DAO (Data Access Object)
**Referencia:** `dao/ProductoDAO.java`

- Constantes SQL como `private static final String SQL_XXX = "..."` arriba del todo
- `try-with-resources` para Connection, PreparedStatement, ResultSet
- `PreparedStatement` SIEMPRE (nunca concatenar strings SQL)
- Metodo privado `mapearXxx(ResultSet rs)` para mapeo
- `Logger` con `LOGGER.log(Level.SEVERE, "mensaje", exception)` en catch

### 4.3 Servlets
**Referencia:** `controlador/ProductoServlet.java`, `LoginServlet.java`

- Switch expression de Java 14+: `switch (accion) { case "x" -> metodo(); default -> ... }`
- Logging en cada entrada: `LOGGER.info("GET - Acción: " + accion)`
- Separar cada accion en metodo privado
- Validacion de parametros antes de procesar
- Forward a JSP con `request.getRequestDispatcher(...).forward(request, response)`
- Redirect POST-REDIRECT-GET despues de writes

### 4.4 JSP Views
**Reglas estrictas:**
- NO scriptlets `<% %>` → solo JSTL y EL
- `jakarta.tags.core` (no `java.sun.com/jsp/jstl/core`)
- `<c:out value="..." />` SIEMPRE para escapar output (XSS prevention)
- CSS classes con prefijo del componente
- Header/footer compartidos (evitar duplicacion)
- Footer con copyright dinamico

### 4.5 CSS (estilo.css)
**Reglas:**
- Paleta de colores SENA: verde primario `#00664A`, verde secundario `#008C6E`
- NO usar colores genericos como `#667eea` (purple gradient no-SENA)
- Gradientes sutiles, colores institucionales
- `box-sizing: border-box` en reset
- Transiciones suaves en hover states
- Grid responsive con `grid-template-columns: repeat(auto-fit, minmax(250px, 1fr))`

---

## 5. Patrones PROHIBIDOS

| Patron | Alternativa |
|--------|-------------|
| `alert()` | Componente `MensajeFlash` o `SnackBar` |
| `confirm()` | Modal de confirmacion personalizado |
| `prompt()` | Formulario inline con input |
| `password: 'temp123'` hardcoded | Enviar solo campos modificados |
| Scriptlets `<% %>` en JSP | JSTL + EL |
| `javax.servlet.*` | `jakarta.servlet.*` |
| PreparedStatement sin try-with-resources | `try (Connection conn = ...; PreparedStatement ps = ...)` |
| Texto plano en contrasenas | BCrypt (`at.favre.lib:bcrypt`) |
| URL hardcoded | `import.meta.env.VITE_API_URL` o `.env` |

---

## 6. Checklist de Calidad por Componente

Cada nuevo componente debe pasar:

- [ ] Cubre loading / error / empty / data states?
- [ ] Sin `alert()` / `confirm()` / `prompt()`?
- [ ] Sin valores hardcoded sensibles?
- [ ] Sigue la paleta SENA (`#00664A`)?
- [ ] Responsive (mobile-first)?
- [ ] Logging de operaciones importantes?
- [ ] Validacion de entrada (backend + frontend)?
- [ ] Nombres consistentes con el resto del proyecto?
- [ ] Sin duplicacion de codigo (DRY)?
- [ ] Importa desde `jakarta.*` (no `javax.*`)?
