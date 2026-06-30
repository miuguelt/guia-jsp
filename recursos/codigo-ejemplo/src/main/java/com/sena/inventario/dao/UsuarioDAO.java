package com.sena.inventario.dao;

import com.sena.inventario.modelo.Usuario;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Clase DAO (Data Access Object) para la entidad Usuario.
 * Implementa operaciones CRUD usando JDBC con PreparedStatement.
 */
public class UsuarioDAO {
    
    private static final Logger LOGGER = Logger.getLogger(UsuarioDAO.class.getName());
    
    // Consultas SQL
    private static final String SQL_INSERT = 
        "INSERT INTO usuarios (username, password, nombre_completo, email, rol_id, estado) " +
        "VALUES (?, ?, ?, ?, ?, ?)";
    private static final String SQL_SELECT_ALL = 
        "SELECT id, username, password, nombre_completo, email, rol_id, estado, " +
        "fecha_creacion, ultimo_acceso FROM usuarios ORDER BY id";
    private static final String SQL_SELECT_BY_ID = 
        "SELECT id, username, password, nombre_completo, email, rol_id, estado, " +
        "fecha_creacion, ultimo_acceso FROM usuarios WHERE id = ?";
    private static final String SQL_SELECT_BY_USERNAME = 
        "SELECT id, username, password, nombre_completo, email, rol_id, estado, " +
        "fecha_creacion, ultimo_acceso FROM usuarios WHERE username = ?";
    private static final String SQL_UPDATE = 
        "UPDATE usuarios SET username = ?, nombre_completo = ?, email = ?, " +
        "rol_id = ?, estado = ? WHERE id = ?";
    private static final String SQL_UPDATE_PASSWORD = 
        "UPDATE usuarios SET password = ? WHERE id = ?";
    private static final String SQL_UPDATE_ULTIMO_ACCESO = 
        "UPDATE usuarios SET ultimo_acceso = CURRENT_TIMESTAMP WHERE id = ?";
    private static final String SQL_DELETE = 
        "DELETE FROM usuarios WHERE id = ?";
    
    /**
     * Inserta un nuevo usuario en la base de datos.
     * 
     * @param usuario Objeto Usuario con los datos a insertar
     * @return true si la inserción fue exitosa, false en caso contrario
     */
    public boolean insertar(Usuario usuario) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {
            
            ps.setString(1, usuario.username());
            ps.setString(2, usuario.password());
            ps.setString(3, usuario.nombreCompleto());
            ps.setString(4, usuario.email());
            ps.setInt(5, usuario.rolId());
            ps.setBoolean(6, usuario.estado());
            
            int filasAfectadas = ps.executeUpdate();
            LOGGER.info("Usuario insertado: " + usuario.username() + 
                       " - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al insertar usuario", e);
            return false;
        }
    }
    
    /**
     * Obtiene todos los usuarios de la base de datos.
     * 
     * @return Lista de objetos Usuario
     */
    public List<Usuario> listarTodos() {
        List<Usuario> usuarios = new ArrayList<>();
        
        try (Connection conn = ConexionDB.conectar();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(SQL_SELECT_ALL)) {
            
            while (rs.next()) {
                usuarios.add(mapearUsuario(rs));
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al listar usuarios", e);
        }
        
        return usuarios;
    }
    
    /**
     * Busca un usuario por su ID.
     * 
     * @param id ID del usuario a buscar
     * @return Objeto Usuario si se encuentra, null en caso contrario
     */
    public Usuario buscarPorId(int id) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_BY_ID)) {
            
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearUsuario(rs);
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al buscar usuario por ID: " + id, e);
        }
        
        return null;
    }
    
    /**
     * Busca un usuario por su username.
     * 
     * @param username Nombre de usuario a buscar
     * @return Objeto Usuario si se encuentra, null en caso contrario
     */
    public Usuario buscarPorUsername(String username) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_BY_USERNAME)) {
            
            ps.setString(1, username);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearUsuario(rs);
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al buscar usuario: " + username, e);
        }
        
        return null;
    }
    
    /**
     * Actualiza un usuario existente en la base de datos.
     * 
     * @param usuario Objeto Usuario con los datos actualizados
     * @return true si la actualización fue exitosa, false en caso contrario
     */
    public boolean actualizar(Usuario usuario) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE)) {
            
            ps.setString(1, usuario.username());
            ps.setString(2, usuario.nombreCompleto());
            ps.setString(3, usuario.email());
            ps.setInt(4, usuario.rolId());
            ps.setBoolean(5, usuario.estado());
            ps.setInt(6, usuario.id());
            
            int filasAfectadas = ps.executeUpdate();
            LOGGER.info("Usuario actualizado: " + usuario.id() + 
                       " - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al actualizar usuario", e);
            return false;
        }
    }
    
    /**
     * Actualiza la contraseña de un usuario.
     * 
     * @param id ID del usuario
     * @param nuevaPassword Nueva contraseña encriptada
     * @return true si la actualización fue exitosa, false en caso contrario
     */
    public boolean actualizarPassword(int id, String nuevaPassword) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE_PASSWORD)) {
            
            ps.setString(1, nuevaPassword);
            ps.setInt(2, id);
            
            int filasAfectadas = ps.executeUpdate();
            LOGGER.info("Password actualizada para usuario: " + id);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al actualizar password", e);
            return false;
        }
    }
    
    /**
     * Actualiza la fecha de último acceso de un usuario.
     * 
     * @param id ID del usuario
     * @return true si la actualización fue exitosa, false en caso contrario
     */
    public boolean actualizarUltimoAcceso(int id) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE_ULTIMO_ACCESO)) {
            
            ps.setInt(1, id);
            
            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al actualizar último acceso", e);
            return false;
        }
    }
    
    /**
     * Elimina un usuario de la base de datos.
     * 
     * @param id ID del usuario a eliminar
     * @return true si la eliminación fue exitosa, false en caso contrario
     */
    public boolean eliminar(int id) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_DELETE)) {
            
            ps.setInt(1, id);
            
            int filasAfectadas = ps.executeUpdate();
            LOGGER.info("Usuario eliminado: " + id + " - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al eliminar usuario: " + id, e);
            return false;
        }
    }
    
    /**
     * Mapea un ResultSet a un objeto Usuario.
     * 
     * @param rs ResultSet posicionado en la fila a mapear
     * @return Objeto Usuario con los datos del ResultSet
     * @throws SQLException si hay error en el acceso a datos
     */
    private Usuario mapearUsuario(ResultSet rs) throws SQLException {
        LocalDateTime fechaCreacion = null;
        Timestamp timestampFecha = rs.getTimestamp("fecha_creacion");
        if (timestampFecha != null) {
            fechaCreacion = timestampFecha.toLocalDateTime();
        }
        
        LocalDateTime ultimoAcceso = null;
        Timestamp timestampAcceso = rs.getTimestamp("ultimo_acceso");
        if (timestampAcceso != null) {
            ultimoAcceso = timestampAcceso.toLocalDateTime();
        }
        
        return new Usuario(
            rs.getInt("id"),
            rs.getString("username"),
            rs.getString("password"),
            rs.getString("nombre_completo"),
            rs.getString("email"),
            rs.getInt("rol_id"),
            rs.getBoolean("estado"),
            fechaCreacion,
            ultimoAcceso
        );
    }
}
