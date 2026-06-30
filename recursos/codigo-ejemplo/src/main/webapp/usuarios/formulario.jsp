<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${titulo}" /> - Sistema de Inventario</title>
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
            <h2><c:out value="${titulo}" /></h2>
            <a href="${pageContext.request.contextPath}/usuarios" class="btn btn-secondary">
                ← Volver a la lista
            </a>
        </div>
        
        <c:if test="${param.error == 'campos_obligatorios'}">
            <div class="alert alert-error">
                Los campos marcados con * son obligatorios.
            </div>
        </c:if>
        
        <c:if test="${param.error == 'password_requerida'}">
            <div class="alert alert-error">
                La contraseña es obligatoria para nuevos usuarios.
            </div>
        </c:if>
        
        <form action="${pageContext.request.contextPath}/usuarios" method="POST" class="form-container">
            <input type="hidden" name="accion" value="guardar">
            <input type="hidden" name="id" value="${usuario.id}">
            
            <div class="form-grid">
                <div class="form-group">
                    <label for="username">Usuario: *</label>
                    <input type="text" id="username" name="username" 
                           value="<c:out value='${usuario.username}' />" 
                           placeholder="Nombre de usuario" required>
                </div>
                
                <div class="form-group">
                    <label for="nombreCompleto">Nombre Completo: *</label>
                    <input type="text" id="nombreCompleto" name="nombreCompleto" 
                           value="<c:out value='${usuario.nombreCompleto}' />" 
                           placeholder="Nombre completo" required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email: *</label>
                    <input type="email" id="email" name="email" 
                           value="<c:out value='${usuario.email}' />" 
                           placeholder="correo@ejemplo.com" required>
                </div>
                
                <div class="form-group">
                    <label for="rolId">Rol: *</label>
                    <select id="rolId" name="rolId" required>
                        <option value="">-- Seleccione un rol --</option>
                        <c:forEach var="rol" items="${roles}">
                            <option value="${rol.id}" ${usuario.rolId == rol.id ? 'selected' : ''}>
                                <c:out value="${rol.nombre}" />
                            </option>
                        </c:forEach>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="password">
                        Contraseña: <c:out value="${modo == 'crear' ? '*' : '(dejar vacío para no cambiar)'}" />
                    </label>
                    <input type="password" id="password" name="password" 
                           placeholder="Mínimo 6 caracteres"
                           ${modo == 'crear' ? 'required' : ''}>
                </div>
                
                <div class="form-group">
                    <label for="estado">Estado:</label>
                    <label class="checkbox-label">
                        <input type="checkbox" id="estado" name="estado" 
                               ${usuario.estado || modo == 'crear' ? 'checked' : ''}>
                        Activo
                    </label>
                </div>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    <c:out value="${modo == 'crear' ? 'Crear Usuario' : 'Actualizar Usuario'}" />
                </button>
                <a href="${pageContext.request.contextPath}/usuarios" class="btn btn-secondary">Cancelar</a>
            </div>
        </form>
    </main>
    
    <footer class="footer">
        <div class="container">
            <p>&copy; 2026 SENA - ADSO. Sistema de Inventario MVC.</p>
        </div>
    </footer>
</body>
</html>
