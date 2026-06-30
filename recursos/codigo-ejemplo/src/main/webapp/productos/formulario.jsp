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
                <a href="${pageContext.request.contextPath}/productos" class="active">Productos</a>
                <a href="${pageContext.request.contextPath}/usuarios">Usuarios</a>
            </nav>
        </div>
    </header>
    
    <main class="container main-content">
        <div class="page-header">
            <h2><c:out value="${titulo}" /></h2>
            <a href="${pageContext.request.contextPath}/productos" class="btn btn-secondary">
                ← Volver a la lista
            </a>
        </div>
        
        <c:if test="${param.error == 'campos_obligatorios'}">
            <div class="alert alert-error">
                Los campos marcados con * son obligatorios.
            </div>
        </c:if>
        
        <c:if test="${param.error == 'formato_invalido'}">
            <div class="alert alert-error">
                Error en el formato de los datos. Verifique los valores ingresados.
            </div>
        </c:if>
        
        <form action="${pageContext.request.contextPath}/productos" method="POST" class="form-container">
            <input type="hidden" name="accion" value="guardar">
            <input type="hidden" name="id" value="${producto.id}">
            
            <div class="form-grid">
                <div class="form-group">
                    <label for="codigo">Código: *</label>
                    <input type="text" id="codigo" name="codigo" 
                           value="<c:out value='${producto.codigo}' />" 
                           placeholder="Ej: PROD-001" required>
                </div>
                
                <div class="form-group">
                    <label for="nombre">Nombre: *</label>
                    <input type="text" id="nombre" name="nombre" 
                           value="<c:out value='${producto.nombre}' />" 
                           placeholder="Nombre del producto" required>
                </div>
                
                <div class="form-group">
                    <label for="categoria">Categoría:</label>
                    <select id="categoria" name="categoria">
                        <option value="General">General</option>
                        <option value="Tecnología" ${producto.categoria == 'Tecnología' ? 'selected' : ''}>Tecnología</option>
                        <option value="Accesorios" ${producto.categoria == 'Accesorios' ? 'selected' : ''}>Accesorios</option>
                        <option value="Audio" ${producto.categoria == 'Audio' ? 'selected' : ''}>Audio</option>
                        <option value="Almacenamiento" ${producto.categoria == 'Almacenamiento' ? 'selected' : ''}>Almacenamiento</option>
                        <option value="Impresión" ${producto.categoria == 'Impresión' ? 'selected' : ''}>Impresión</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="precio">Precio: *</label>
                    <input type="number" id="precio" name="precio" step="0.01" min="0"
                           value="<c:out value='${producto.precio}' />" 
                           placeholder="0.00" required>
                </div>
                
                <div class="form-group">
                    <label for="stock">Stock: *</label>
                    <input type="number" id="stock" name="stock" min="0"
                           value="<c:out value='${producto.stock}' />" 
                           placeholder="0" required>
                </div>
                
                <div class="form-group">
                    <label for="estado">Estado:</label>
                    <label class="checkbox-label">
                        <input type="checkbox" id="estado" name="estado" 
                               ${producto.estado || modo == 'crear' ? 'checked' : ''}>
                        Activo
                    </label>
                </div>
            </div>
            
            <div class="form-group full-width">
                <label for="descripcion">Descripción:</label>
                <textarea id="descripcion" name="descripcion" rows="3" 
                          placeholder="Descripción detallada del producto"><c:out value='${producto.descripcion}' /></textarea>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    <c:out value="${modo == 'crear' ? 'Crear Producto' : 'Actualizar Producto'}" />
                </button>
                <a href="${pageContext.request.contextPath}/productos" class="btn btn-secondary">Cancelar</a>
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
