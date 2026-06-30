<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lista de Productos - Sistema de Inventario</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <h1>Sistema de Inventario</h1>
            <nav class="nav">
                <a href="${pageContext.request.contextPath}/">Inicio</a>
                <a href="${pageContext.request.contextPath}/productos" class="active">Productos</a>
                <a href="${pageContext.request.contextPath}/usuarios">Usuarios</a>
            </nav>
        </div>
    </header>
    
    <main class="container main-content">
        <div class="page-header">
            <h2>Lista de Productos</h2>
            <a href="${pageContext.request.contextPath}/productos?accion=nuevo" class="btn btn-success">
                + Nuevo Producto
            </a>
        </div>
        
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                <c:out value="${error}" />
            </div>
        </c:if>
        
        <c:if test="${not empty categoriaBuscada}">
            <div class="alert alert-info">
                Mostrando productos de categoría: <strong><c:out value="${categoriaBuscada}" /></strong>
                (<c:out value="${totalProductos}" /> encontrados)
                <a href="${pageContext.request.contextPath}/productos">Ver todos</a>
            </div>
        </c:if>
        
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Código</th>
                        <th>Nombre</th>
                        <th>Categoría</th>
                        <th>Precio</th>
                        <th>Stock</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty productos}">
                            <tr>
                                <td colspan="8" class="no-data">No hay productos registrados</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="producto" items="${productos}">
                                <tr>
                                    <td><c:out value="${producto.id}" /></td>
                                    <td><c:out value="${producto.codigo}" /></td>
                                    <td><c:out value="${producto.nombre}" /></td>
                                    <td><c:out value="${producto.categoria}" /></td>
                                    <td class="text-right">$<c:out value="${producto.precio}" /></td>
                                    <td class="text-center">
                                        <span class="badge ${producto.stock < 15 ? 'badge-warning' : 'badge-success'}">
                                            <c:out value="${producto.stock}" />
                                        </span>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge ${producto.estado ? 'badge-success' : 'badge-danger'}">
                                            <c:out value="${producto.estado ? 'Activo' : 'Inactivo'}" />
                                        </span>
                                    </td>
                                    <td class="actions">
                                        <a href="${pageContext.request.contextPath}/productos?accion=editar&id=${producto.id}" 
                                           class="btn btn-small btn-warning">Editar</a>
                                        <a href="${pageContext.request.contextPath}/productos?accion=eliminar&id=${producto.id}" 
                                           class="btn btn-small btn-danger"
                                           onclick="return confirm('¿Está seguro de eliminar este producto?');">Eliminar</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
        
        <div class="summary">
            <p>Total de productos: <strong><c:out value="${totalProductos}" /></strong></p>
        </div>
    </main>
    
    <footer class="footer">
        <div class="container">
            <p>&copy; 2026 SENA - ADSO. Sistema de Inventario MVC.</p>
        </div>
    </footer>
</body>
</html>
