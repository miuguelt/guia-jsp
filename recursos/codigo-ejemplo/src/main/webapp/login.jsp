<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Sistema de Inventario</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body class="login-body">
    <div class="login-container">
        <div class="login-header">
            <h1>Sistema de Inventario</h1>
            <p>SENA - ADSO</p>
        </div>
        
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                <c:out value="${error}" />
            </div>
        </c:if>
        
        <form action="${pageContext.request.contextPath}/login" method="POST" class="login-form">
            <div class="form-group">
                <label for="username">Usuario:</label>
                <input type="text" id="username" name="username" 
                       placeholder="Ingrese su usuario" required autofocus>
            </div>
            
            <div class="form-group">
                <label for="password">Contraseña:</label>
                <input type="password" id="password" name="password" 
                       placeholder="Ingrese su contraseña" required>
            </div>
            
            <button type="submit" class="btn btn-primary btn-block">Iniciar Sesión</button>
        </form>
        
        <div class="login-footer">
            <p><small>Usuarios de prueba: admin / cliente1 / invitado (contraseña: admin123)</small></p>
        </div>
    </div>
</body>
</html>
