# Guía de Aprendizaje Guiada por la Interfaz Interactiva - JSP + MVC → FastAPI → React → Flutter

Esta guía te enseña a navegar, ejecutar e interactuar con el proyecto completo **utilizando como hilo conductor la interfaz web educativa e interactiva**. Está diseñada bajo el enfoque de Formación Profesional Integral (FPI) del SENA para aprendices de ADSO.

---

## 🚀 1. El Punto de Partida: Levantar la Interfaz Interactiva

El proyecto cuenta con un portal web educativo local (puerto `8024`) con simuladores interactivos de flujo, comparadores de código y lecciones visuales.

### Cómo Iniciar la Interfaz Web:
Abre una terminal de PowerShell como Administrador en la raíz del proyecto `guia-jsp` y ejecuta:
```powershell
.\start-windows.ps1
```
*Este script inicia un servidor web ligero local.*

*   **URL de Acceso:** Abre tu navegador y dirígete a **`http://localhost:8024`** (o abre directamente el archivo [web/index.html](file:///c:/Users/Miguel/Documents/Aplicaciones/_projects/guia-jsp/web/index.html) en tu navegador).

---

## 🎛️ 2. Entendiendo la Interfaz del Portal de Aprendizaje

Al ingresar a **`http://localhost:8024`**, verás una interfaz web premium con un panel de control educativo:

```
┌────────────────────────────────────────────────────────────────────────┐
│  🎓 SENA ADSO   [🔎 Buscar en la guía... Ctrl+K]          🌙 Tema / ☀️ │
├───────────────┬────────────────────────────────────────────────────────┤
│  INTRODUCCIÓN │                                                        │
│  ■ Inicio     │                     H E R O                            │
│  ■ Identific. │           Full Stack Web: JSP → FastAPI                │
│               │                                                        │
│  CONCEPTOS    ├────────────────────────────────────────────────────────┤
│  ■ Reflexión  │ 📊 SIMULADOR DE FLUJO HTTP MVC (Interactivo)           │
│  ■ Fundam.    │  [ Vista JSP ] ──> [ Servlet ] ──> [ DAO ] ──> [ DB ]  │
│               │                                                        │
│  PRACTICA     ├────────────────────────────────────────────────────────┤
│  ■ Simuladores│ ⚡ COMPARADOR DE CÓDIGO (JDBC vs JPA ORM)              │
│  ■ Tutorial   │                                                        │
└───────────────┴────────────────────────────────────────────────────────┘
```

### Funciones Clave de la Interfaz:
1.  **Panel Lateral de Progreso (Sidebar):** Muestra el temario completo. A medida que lees y completas secciones, la barra de progreso en la parte inferior se actualizará automáticamente. Puedes restablecer el progreso con el botón de reinicio (icono 🔄).
2.  **Búsqueda Global Integrada (Ctrl + K o 🔍):** Abre un buscador en tiempo real para localizar rápidamente conceptos, clases Java o comandos de base de datos dentro del portal.
3.  **Interruptor de Tema (🌙/☀️):** Cambia entre modo oscuro (Dark Mode) y claro de forma fluida.

---

## 🔬 3. Guía de Aprendizaje Paso a Paso en la Interfaz

Sigue este recorrido interactivo en la pantalla para comprender el proyecto y cómo se relaciona con el código:

### Paso A: Reflexión Inicial - El Caso del "Código Espagueti"
*   **En la Interfaz (Sección "Reflexión Inicial"):** Analiza la simulación y discusión sobre los problemas de mezclar código Java dentro de archivos HTML (scriptlets).
*   **En el Código Real:** Compara el antipatrón de scriptlets clásicos con las vistas JSP limpias del proyecto (ej: [index.jsp](file:///c:/Users/Miguel/Documents/Aplicaciones/_projects/guia-jsp/recursos/codigo-ejemplo/src/main/webapp/index.jsp) y [productos/lista.jsp](file:///c:/Users/Miguel/Documents/Aplicaciones/_projects/guia-jsp/recursos/codigo-ejemplo/src/main/webapp/productos/lista.jsp)), las cuales usan estrictamente **JSTL 3.0** (`c:forEach`, `c:if`) para pintar los datos de la base de datos sin incrustar Java directamente.

---

### Paso B: Uso de los Simuladores Interactivos
Dirígete a la sección **Simuladores** en el panel lateral. Es el núcleo didáctico de la interfaz.

#### 1. Simulador del Flujo HTTP MVC
*   **Cómo usarlo:** Haz clic en los botones interactivos que representan las capas de la arquitectura clásica.
*   **Qué observar:**
    1.  **Petición (Request):** El cliente envía una petición HTTP (ej: `/productos?accion=listar`).
    2.  **Controlador (Servlet):** Recibe la petición. Abre en tu editor el archivo [ProductoServlet.java](file:///c:/Users/Miguel/Documents/Aplicaciones/_projects/guia-jsp/recursos/codigo-ejemplo/src/main/java/com/sena/inventario/controlador/ProductoServlet.java) y observa cómo el switch-pattern de Java 21 gestiona la redirección.
    3.  **DAO (Data Access Object):** El servlet invoca al DAO para consultar la base de datos. Revisa el archivo [ProductoDAO.java](file:///c:/Users/Miguel/Documents/Aplicaciones/_projects/guia-jsp/recursos/codigo-ejemplo/src/main/java/com/sena/inventario/dao/ProductoDAO.java).
    4.  **Modelo (Records):** El DAO mapea los registros a clases inmutables Record: [Producto.java](file:///c:/Users/Miguel/Documents/Aplicaciones/_projects/guia-jsp/recursos/codigo-ejemplo/src/main/java/com/sena/inventario/modelo/Producto.java).
    5.  **Vista (JSP):** Se hace un *forward* de los datos a la vista en [lista.jsp](file:///c:/Users/Miguel/Documents/Aplicaciones/_projects/guia-jsp/recursos/codigo-ejemplo/src/main/webapp/productos/lista.jsp) para renderizar la tabla al cliente.

#### 2. Simulador Comparativo: JDBC Tradicional vs ORM Moderno
*   **Cómo usarlo:** Alterna las pestañas interactivas **JDBC (Java)** y **SQLAlchemy ORM (Python)** en el simulador.
*   **Qué observar:** Verás cómo el DAO clásico requiere abrir conexiones, preparar sentencias SQL, capturar excepciones y mapear manualmente los ResultSet, mientras que el ORM moderna en FastAPI maneja las entidades como objetos Python nativos de forma limpia.

---

### Paso C: Ejecución y Práctica Guiada
El portal te guiará visualmente a levantar los servidores físicos paso a paso.

#### 1. Correr el Monolito JSP + MVC
*   **En la Interfaz (Sección "Configuración PostgreSQL" y "Tutorial"):** Sigue los pasos de configuración de variables y el script SQL.
*   **Ejecución Física:** Abre PowerShell y ejecuta el script de arranque:
    ```powershell
    .\run-project-jsp.ps1
    ```
*   **Interactuar con la aplicación desplegada:** Ve a `http://localhost:8080/inventario-mvc-1.0/`.
    *   Prueba iniciar sesión con `admin` y `admin123`. Crea un producto, edita su stock y observa cómo el indicador visual de la lista cambia a color de alerta si el stock disminuye de 15 unidades.
    *   Verifica cómo se refleja este cambio directamente en las tablas físicas usando tu gestor de base de datos.

#### 2. Levantar la API FastAPI y Frontend React
*   **En la Interfaz (Sección "FastAPI" y "React"):** Observa los diagramas del flujo de autenticación mediante JWT (JSON Web Tokens) y Axios.
*   **Ejecución Física:** Para arrancar de manera simplificada ambos servidores de forma nativa en Windows:
    ```powershell
    .\start-fullstack.ps1
    ```
*   **Interactuar:** Abre tu navegador en **`http://localhost:5173`** (React) e interactúa con el inventario moderno consumiendo los servicios en **`http://localhost:8000/docs`** (FastAPI Swagger UI).

#### 3. Probar la Aplicación Móvil Flutter
*   **En la Interfaz (Enlace "Guía Flutter + OpenAPI"):** Abre la guía interactiva específica haciendo clic en el menú lateral.
*   **Ejecución Física:** Inicia el backend y compila el entorno móvil ejecutando:
    ```powershell
    .\start-flutter.ps1
    ```
*   Navega por la aplicación y revisa cómo los estados son administrados reactivamente con Riverpod.

---

## 🐳 4. Opciones de Orquestación Dockerizadas

En la sección final de la interfaz (**"Despliegue Docker"**), se detallan los perfiles de contenedores. Para aplicarlo directamente en tu máquina:

1.  **Solo Base de Datos y JSP:**
    ```bash
    docker compose up -d
    ```
2.  **Entorno FastAPI + React + PostgreSQL:**
    ```bash
    docker compose -f docker-compose.fullstack.yml up -d
    ```
3.  **Microservicios completo con Flutter Web:**
    ```bash
    docker compose -f docker-compose.microservices.yml up -d
    ```
