# Lecciones Aprendidas - Guia JSP + MVC

## Reglas del Proyecto

- Jakarta EE 10 usa `jakarta.servlet.*`, NO `javax.servlet.*`
- JDK 21 permite usar `record` para entidades inmutables
- JSTL 3.0 usa URI `jakarta.tags.core`, NO `http://java.sun.com/jsp/jstl/core`
- Tomcat 10.1+ es requerido para Jakarta EE 10 (no Tomcat 9)
- PostgreSQL: usar `SERIAL` para auto-incremento, `TIMESTAMP` para fechas
- Maven: `jakarta.servlet-api` debe tener scope `provided` (Tomcat lo provee)
- BCrypt para encriptacion de contrasenas, nunca texto plano
- PreparedStatement SIEMPRE para prevenir SQL injection
- try-with-resources para cerrar Connection, Statement, ResultSet
- Las JSP NO deben tener scriptlets (<% %>), solo JSTL y EL
- Docker: imagen base `tomcat:10.1-jdk21-temurin-jakarta` para JDK 21

## Estandar de Presentacion de Codigo

Ver el estandar completo y detallado en:
`.devbrain/knowledge/estandar_codigo.md`

**Resumen ejecutivo:**
- Todo componente debe cubrir: loading, error, empty, data
- PROHIBIDO: `alert()`, `confirm()`, `prompt()`, `javax.*`, scriptlets, texto plano
- Paleta SENA: `#00664A` verde primario (NO purple gradient generico)
- Referencias gold standard por stack:
  - React: `ProductoLista.jsx`, `ProductoCard.jsx`, `api.js`, `AuthContext.jsx`
  - FastAPI: `routers/producto.py`, `main.py`, `schemas/producto.py`
  - Flutter: `theme.dart`, `api_client.dart`, `auth_provider.dart`, `login_screen.dart`
  - Java: `modelo/Producto.java` (record), `dao/ProductoDAO.java`, `LoginServlet.java`
