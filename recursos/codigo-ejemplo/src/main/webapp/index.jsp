<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio - Sistema de Inventario</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <h1>Sistema de Inventario</h1>
            <nav class="nav">
                <a href="${pageContext.request.contextPath}/">Inicio</a>
                <a href="${pageContext.request.contextPath}/productos">Productos</a>
                <a href="${pageContext.request.contextPath}/usuarios">Usuarios</a>
                <c:if test="${not empty sessionScope.usuario}">
                    <span class="user-info">
                        Bienvenido, <c:out value="${sessionScope.usuarioNombre}" />
                        (<c:out value="${sessionScope.rolId == 1 ? 'Admin' : 'Usuario'}" />)
                    </span>
                </c:if>
            </nav>
        </div>
    </header>
    
    <main class="container main-content">
        <div class="welcome-section">
            <h2>Bienvenido al Sistema de Inventario</h2>
            <p>Este sistema permite gestionar productos, usuarios y roles de manera eficiente.</p>
        </div>
        
        <div class="dashboard-grid">
            <div class="card">
                <h3>Productos</h3>
                <p>Gestiona el inventario de productos del sistema.</p>
                <a href="${pageContext.request.contextPath}/productos" class="btn btn-primary">
                    Ir a Productos
                </a>
            </div>
            
            <div class="card">
                <h3>Usuarios</h3>
                <p>Administra los usuarios y sus roles.</p>
                <a href="${pageContext.request.contextPath}/usuarios" class="btn btn-primary">
                    Ir a Usuarios
                </a>
            </div>
            
            <div class="card">
                <h3>Información</h3>
                <p>Desarrollado con JSP + MVC + Jakarta EE + JDK 21</p>
                <p class="tech-info">
                    <strong>Tecnologías:</strong><br>
                    Jakarta Servlet 6.0<br>
                    Jakarta JSTL 3.0<br>
                    PostgreSQL<br>
                    Maven
                </p>
            </div>
        </div>
        
        <c:if test="${empty sessionScope.usuario}">
            <div class="login-prompt">
                <p>Para acceder a todas las funcionalidades, por favor inicie sesión.</p>
                <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">
                    Iniciar Sesión
                </a>
            </div>
        </c:if>
    </main>
    
    <footer class="footer">
        <div class="container">
            <p>&copy; 2026 SENA - ADSO. Sistema de Inventario MVC.</p>
        </div>
    </footer>
</body>
</html>
