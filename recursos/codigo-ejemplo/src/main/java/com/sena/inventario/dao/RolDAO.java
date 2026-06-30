package com.sena.inventario.dao;

import com.sena.inventario.modelo.Rol;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Clase DAO (Data Access Object) para la entidad Rol.
 * Implementa operaciones CRUD usando JDBC con PreparedStatement
 * para prevenir inyecciones SQL.
 */
public class RolDAO {
    
    private static final Logger LOGGER = Logger.getLogger(RolDAO.class.getName());
    
    // Consultas SQL
    private static final String SQL_INSERT = 
        "INSERT INTO roles (nombre, descripcion, estado) VALUES (?, ?, ?)";
    private static final String SQL_SELECT_ALL = 
        "SELECT id, nombre, descripcion, estado, fecha_creacion FROM roles ORDER BY id";
    private static final String SQL_SELECT_BY_ID = 
        "SELECT id, nombre, descripcion, estado, fecha_creacion FROM roles WHERE id = ?";
    private static final String SQL_UPDATE = 
        "UPDATE roles SET nombre = ?, descripcion = ?, estado = ? WHERE id = ?";
    private static final String SQL_DELETE = 
        "DELETE FROM roles WHERE id = ?";
    
    /**
     * Inserta un nuevo rol en la base de datos.
     * 
     * @param rol Objeto Rol con los datos a insertar
     * @return true si la inserción fue exitosa, false en caso contrario
     */
    public boolean insertar(Rol rol) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {
            
            ps.setString(1, rol.nombre());
            ps.setString(2, rol.descripcion());
            ps.setBoolean(3, rol.estado());
            
            int filasAfectadas = ps.executeUpdate();
            LOGGER.info("Rol insertado: " + rol.nombre() + " - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al insertar rol", e);
            return false;
        }
    }
    
    /**
     * Obtiene todos los roles de la base de datos.
     * 
     * @return Lista de objetos Rol
     */
    public List<Rol> listarTodos() {
        List<Rol> roles = new ArrayList<>();
        
        try (Connection conn = ConexionDB.conectar();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(SQL_SELECT_ALL)) {
            
            while (rs.next()) {
                roles.add(mapearRol(rs));
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al listar roles", e);
        }
        
        return roles;
    }
    
    /**
     * Busca un rol por su ID.
     * 
     * @param id ID del rol a buscar
     * @return Objeto Rol si se encuentra, null en caso contrario
     */
    public Rol buscarPorId(int id) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_BY_ID)) {
            
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearRol(rs);
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al buscar rol por ID: " + id, e);
        }
        
        return null;
    }
    
    /**
     * Actualiza un rol existente en la base de datos.
     * 
     * @param rol Objeto Rol con los datos actualizados
     * @return true si la actualización fue exitosa, false en caso contrario
     */
    public boolean actualizar(Rol rol) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE)) {
            
            ps.setString(1, rol.nombre());
            ps.setString(2, rol.descripcion());
            ps.setBoolean(3, rol.estado());
            ps.setInt(4, rol.id());
            
            int filasAfectadas = ps.executeUpdate();
            LOGGER.info("Rol actualizado: " + rol.id() + " - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al actualizar rol", e);
            return false;
        }
    }
    
    /**
     * Elimina un rol de la base de datos.
     * 
     * @param id ID del rol a eliminar
     * @return true si la eliminación fue exitosa, false en caso contrario
     */
    public boolean eliminar(int id) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_DELETE)) {
            
            ps.setInt(1, id);
            
            int filasAfectadas = ps.executeUpdate();
            LOGGER.info("Rol eliminado: " + id + " - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al eliminar rol: " + id, e);
            return false;
        }
    }
    
    /**
     * Mapea un ResultSet a un objeto Rol.
     * 
     * @param rs ResultSet posicionado en la fila a mapear
     * @return Objeto Rol con los datos del ResultSet
     * @throws SQLException si hay error en el acceso a datos
     */
    private Rol mapearRol(ResultSet rs) throws SQLException {
        LocalDateTime fechaCreacion = null;
        Timestamp timestamp = rs.getTimestamp("fecha_creacion");
        if (timestamp != null) {
            fechaCreacion = timestamp.toLocalDateTime();
        }
        
        return new Rol(
            rs.getInt("id"),
            rs.getString("nombre"),
            rs.getString("descripcion"),
            rs.getBoolean("estado"),
            fechaCreacion
        );
    }
}
