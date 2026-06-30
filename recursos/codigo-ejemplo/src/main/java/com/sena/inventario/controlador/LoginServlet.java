package com.sena.inventario.controlador;

import com.sena.inventario.dao.UsuarioDAO;
import com.sena.inventario.modelo.Usuario;
import com.sena.inventario.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet para manejar la autenticación de usuarios.
 * Procesa las peticiones GET (mostrar formulario) y POST (validar credenciales).
 */
@WebServlet({"/login", "/LoginServlet"})
public class LoginServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(LoginServlet.class.getName());
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();
    
    /**
     * Muestra el formulario de login.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Si ya hay sesión activa, redirigir al inicio
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        
        // Mostrar formulario de login
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
    
    /**
     * Procesa el formulario de login.
     * Valida las credenciales y crea la sesión del usuario.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        LOGGER.info("Intento de login para usuario: " + username);
        
        // Validar campos vacíos
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Usuario y contraseña son obligatorios");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        // Buscar usuario en la base de datos
        Usuario usuario = usuarioDAO.buscarPorUsername(username.trim());
        
        // Verificar si el usuario existe y está activo
        if (usuario == null || !usuario.estado()) {
            LOGGER.warning("Usuario no encontrado o inactivo: " + username);
            request.setAttribute("error", "Usuario o contraseña incorrectos");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        // Verificar la contraseña
        if (!PasswordUtil.verificar(password, usuario.password())) {
            LOGGER.warning("Contraseña incorrecta para usuario: " + username);
            request.setAttribute("error", "Usuario o contraseña incorrectos");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        // Login exitoso - Crear sesión
        HttpSession session = request.getSession(true);
        session.setAttribute("usuario", usuario);
        session.setAttribute("usuarioId", usuario.id());
        session.setAttribute("usuarioNombre", usuario.nombreCompleto());
        session.setAttribute("rolId", usuario.rolId());
        session.setMaxInactiveInterval(30 * 60); // 30 minutos
        
        // Actualizar último acceso
        usuarioDAO.actualizarUltimoAcceso(usuario.id());
        
        LOGGER.info("Login exitoso para usuario: " + username);
        
        // Redirigir según el rol
        response.sendRedirect(request.getContextPath() + "/");
    }
    
    /**
     * Cierra la sesión del usuario.
     */
    public void logout(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
