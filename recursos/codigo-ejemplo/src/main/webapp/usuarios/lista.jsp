<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lista de Usuarios - Sistema de Inventario</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <h1>Sistema de Inventario</h1>
            <nav class="nav">
                <a href="${pageContext.request.contextPath}/">Inicio</a>
                <a href="${pageContext.request.contextPath}/productos">Productos</a>
                <a href="${pageContext.request.contextPath}/usuarios" class="active">Usuarios</a>
            </nav>
        </div>
    </header>
    
    <main class="container main-content">
        <div class="page-header">
            <h2>Lista de Usuarios</h2>
            <a href="${pageContext.request.contextPath}/usuarios?accion=nuevo" class="btn btn-success">
                + Nuevo Usuario
            </a>
        </div>
        
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                <c:out value="${error}" />
            </div>
        </c:if>
        
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Usuario</th>
                        <th>Nombre Completo</th>
                        <th>Email</th>
                        <th>Rol</th>
                        <th>Estado</th>
                        <th>Fecha Creación</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty usuarios}">
                            <tr>
                                <td colspan="8" class="no-data">No hay usuarios registrados</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="usuario" items="${usuarios}">
                                <tr>
                                    <td><c:out value="${usuario.id}" /></td>
                                    <td><c:out value="${usuario.username}" /></td>
                                    <td><c:out value="${usuario.nombreCompleto}" /></td>
                                    <td><c:out value="${usuario.email}" /></td>
                                    <td>
                                        <c:forEach var="rol" items="${roles}">
                                            <c:if test="${rol.id == usuario.rolId}">
                                                <span class="badge badge-info">
                                                    <c:out value="${rol.nombre}" />
                                                </span>
                                            </c:if>
                                        </c:forEach>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge ${usuario.estado ? 'badge-success' : 'badge-danger'}">
                                            <c:out value="${usuario.estado ? 'Activo' : 'Inactivo'}" />
                                        </span>
                                    </td>
                                    <td>
                                        <c:out value="${usuario.fechaCreacion}" />
                                    </td>
                                    <td class="actions">
                                        <a href="${pageContext.request.contextPath}/usuarios?accion=editar&id=${usuario.id}" 
                                           class="btn btn-small btn-warning">Editar</a>
                                        <a href="${pageContext.request.contextPath}/usuarios?accion=eliminar&id=${usuario.id}" 
                                           class="btn btn-small btn-danger"
                                           onclick="return confirm('¿Está seguro de eliminar este usuario?');">Eliminar</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
        
        <div class="summary">
            <p>Total de usuarios: <strong><c:out value="${totalUsuarios}" /></strong></p>
        </div>
    </main>
    
    <footer class="footer">
        <div class="container">
            <p>&copy; 2026 SENA - ADSO. Sistema de Inventario MVC.</p>
        </div>
    </footer>
</body>
</html>
