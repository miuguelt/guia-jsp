package com.sena.inventario.controlador;

import com.sena.inventario.dao.RolDAO;
import com.sena.inventario.dao.UsuarioDAO;
import com.sena.inventario.modelo.Rol;
import com.sena.inventario.modelo.Usuario;
import com.sena.inventario.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet para manejar las operaciones CRUD de Usuarios.
 * Procesa las peticiones GET y POST para listar, crear, editar y eliminar usuarios.
 */
@WebServlet({"/usuarios", "/UsuariosServlet"})
public class UsuarioServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(UsuarioServlet.class.getName());
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();
    private final RolDAO rolDAO = new RolDAO();
    
    /**
     * Maneja las peticiones GET.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        if (accion == null) {
            accion = "listar";
        }
        
        LOGGER.info("GET - Acción: " + accion);
        
        switch (accion) {
            case "nuevo" -> mostrarFormularioNuevo(request, response);
            case "editar" -> mostrarFormularioEditar(request, response);
            case "eliminar" -> eliminarUsuario(request, response);
            default -> listarUsuarios(request, response);
        }
    }
    
    /**
     * Maneja las peticiones POST.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        
        LOGGER.info("POST - Acción: " + accion);
        
        if ("guardar".equals(accion)) {
            guardarUsuario(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/usuarios");
        }
    }
    
    /**
     * Lista todos los usuarios y los envía a la vista.
     */
    private void listarUsuarios(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Usuario> usuarios = usuarioDAO.listarTodos();
        List<Rol> roles = rolDAO.listarTodos();
        
        request.setAttribute("usuarios", usuarios);
        request.setAttribute("roles", roles);
        request.setAttribute("totalUsuarios", usuarios.size());
        request.getRequestDispatcher("/usuarios/lista.jsp").forward(request, response);
    }
    
    /**
     * Muestra el formulario para crear un nuevo usuario.
     */
    private void mostrarFormularioNuevo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Rol> roles = rolDAO.listarTodos();
        request.setAttribute("roles", roles);
        request.setAttribute("modo", "crear");
        request.setAttribute("titulo", "Nuevo Usuario");
        request.getRequestDispatcher("/usuarios/formulario.jsp").forward(request, response);
    }
    
    /**
     * Muestra el formulario para editar un usuario existente.
     */
    private void mostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Usuario usuario = usuarioDAO.buscarPorId(id);
        
        if (usuario == null) {
            request.setAttribute("error", "Usuario no encontrado");
            listarUsuarios(request, response);
            return;
        }
        
        List<Rol> roles = rolDAO.listarTodos();
        request.setAttribute("usuario", usuario);
        request.setAttribute("roles", roles);
        request.setAttribute("modo", "editar");
        request.setAttribute("titulo", "Editar Usuario");
        request.getRequestDispatcher("/usuarios/formulario.jsp").forward(request, response);
    }
    
    /**
     * Guarda un usuario nuevo o actualiza uno existente.
     */
    private void guardarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        try {
            // Obtener parámetros del formulario
            String idStr = request.getParameter("id");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String nombreCompleto = request.getParameter("nombreCompleto");
            String email = request.getParameter("email");
            String rolIdStr = request.getParameter("rolId");
            String estadoStr = request.getParameter("estado");
            
            // Validar campos obligatorios
            if (username == null || username.trim().isEmpty() ||
                nombreCompleto == null || nombreCompleto.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                rolIdStr == null || rolIdStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + 
                    "/usuarios?accion=nuevo&error=campos_obligatorios");
                return;
            }
            
            int rolId = Integer.parseInt(rolIdStr.trim());
            boolean estado = estadoStr != null && "on".equals(estadoStr);
            
            if (idStr == null || idStr.trim().isEmpty()) {
                // Crear nuevo usuario
                if (password == null || password.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + 
                        "/usuarios?accion=nuevo&error=password_requerida");
                    return;
                }
                
                // Encriptar contraseña
                String passwordEncriptada = PasswordUtil.encriptar(password.trim());
                
                Usuario usuario = new Usuario(
                    username.trim(),
                    passwordEncriptada,
                    nombreCompleto.trim(),
                    email.trim(),
                    rolId
                );
                
                boolean exito = usuarioDAO.insertar(usuario);
                LOGGER.info("Usuario creado: " + (exito ? "éxito" : "fallo"));
                
            } else {
                // Actualizar usuario existente
                int id = Integer.parseInt(idStr);
                
                Usuario usuario = new Usuario(
                    id,
                    username.trim(),
                    nombreCompleto.trim(),
                    email.trim(),
                    rolId,
                    estado
                );
                
                boolean exito = usuarioDAO.actualizar(usuario);
                LOGGER.info("Usuario actualizado: " + (exito ? "éxito" : "fallo"));
                
                // Si se proporcionó nueva contraseña, actualizarla
                if (password != null && !password.trim().isEmpty()) {
                    String passwordEncriptada = PasswordUtil.encriptar(password.trim());
                    usuarioDAO.actualizarPassword(id, passwordEncriptada);
                }
            }
            
            response.sendRedirect(request.getContextPath() + "/usuarios");
            
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Error en formato de números", e);
            response.sendRedirect(request.getContextPath() + 
                "/usuarios?accion=nuevo&error=formato_invalido");
        }
    }
    
    /**
     * Elimina un usuario por su ID.
     */
    private void eliminarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean exito = usuarioDAO.eliminar(id);
            LOGGER.info("Usuario eliminado: " + (exito ? "éxito" : "fallo"));
            
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Error al parsear ID de usuario", e);
        }
        
        response.sendRedirect(request.getContextPath() + "/usuarios");
    }
}
