package com.sena.inventario.dao;

import com.sena.inventario.modelo.Producto;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Clase DAO (Data Access Object) para la entidad Producto.
 * Implementa operaciones CRUD usando JDBC con PreparedStatement.
 */
public class ProductoDAO {
    
    private static final Logger LOGGER = Logger.getLogger(ProductoDAO.class.getName());
    
    // Consultas SQL
    private static final String SQL_INSERT = 
        "INSERT INTO productos (codigo, nombre, descripcion, precio, stock, categoria, estado) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?)";
    private static final String SQL_SELECT_ALL = 
        "SELECT id, codigo, nombre, descripcion, precio, stock, categoria, estado, " +
        "fecha_registro, fecha_actualizacion FROM productos ORDER BY id";
    private static final String SQL_SELECT_BY_ID = 
        "SELECT id, codigo, nombre, descripcion, precio, stock, categoria, estado, " +
        "fecha_registro, fecha_actualizacion FROM productos WHERE id = ?";
    private static final String SQL_SELECT_BY_CODIGO = 
        "SELECT id, codigo, nombre, descripcion, precio, stock, categoria, estado, " +
        "fecha_registro, fecha_actualizacion FROM productos WHERE codigo = ?";
    private static final String SQL_SELECT_BY_CATEGORIA = 
        "SELECT id, codigo, nombre, descripcion, precio, stock, categoria, estado, " +
        "fecha_registro, fecha_actualizacion FROM productos WHERE categoria = ? ORDER BY nombre";
    private static final String SQL_SELECT_STOCK_BAJO = 
        "SELECT id, codigo, nombre, descripcion, precio, stock, categoria, estado, " +
        "fecha_registro, fecha_actualizacion FROM productos WHERE stock < ? AND estado = TRUE " +
        "ORDER BY stock ASC";
    private static final String SQL_UPDATE = 
        "UPDATE productos SET codigo = ?, nombre = ?, descripcion = ?, precio = ?, " +
        "stock = ?, categoria = ?, estado = ? WHERE id = ?";
    private static final String SQL_DELETE = 
        "DELETE FROM productos WHERE id = ?";
    
    /**
     * Inserta un nuevo producto en la base de datos.
     * 
     * @param producto Objeto Producto con los datos a insertar
     * @return true si la inserción fue exitosa, false en caso contrario
     */
    public boolean insertar(Producto producto) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {
            
            ps.setString(1, producto.codigo());
            ps.setString(2, producto.nombre());
            ps.setString(3, producto.descripcion());
            ps.setBigDecimal(4, producto.precio());
            ps.setInt(5, producto.stock());
            ps.setString(6, producto.categoria());
            ps.setBoolean(7, producto.estado());
            
            int filasAfectadas = ps.executeUpdate();
            LOGGER.info("Producto insertado: " + producto.codigo() + 
                       " - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al insertar producto", e);
            return false;
        }
    }
    
    /**
     * Obtiene todos los productos de la base de datos.
     * 
     * @return Lista de objetos Producto
     */
    public List<Producto> listarTodos() {
        List<Producto> productos = new ArrayList<>();
        
        try (Connection conn = ConexionDB.conectar();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(SQL_SELECT_ALL)) {
            
            while (rs.next()) {
                productos.add(mapearProducto(rs));
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al listar productos", e);
        }
        
        return productos;
    }
    
    /**
     * Busca un producto por su ID.
     * 
     * @param id ID del producto a buscar
     * @return Objeto Producto si se encuentra, null en caso contrario
     */
    public Producto buscarPorId(int id) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_BY_ID)) {
            
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearProducto(rs);
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al buscar producto por ID: " + id, e);
        }
        
        return null;
    }
    
    /**
     * Busca un producto por su código.
     * 
     * @param codigo Código del producto a buscar
     * @return Objeto Producto si se encuentra, null en caso contrario
     */
    public Producto buscarPorCodigo(String codigo) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_BY_CODIGO)) {
            
            ps.setString(1, codigo);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearProducto(rs);
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al buscar producto por código: " + codigo, e);
        }
        
        return null;
    }
    
    /**
     * Lista productos por categoría.
     * 
     * @param categoria Categoría a filtrar
     * @return Lista de productos de la categoría especificada
     */
    public List<Producto> listarPorCategoria(String categoria) {
        List<Producto> productos = new ArrayList<>();
        
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_BY_CATEGORIA)) {
            
            ps.setString(1, categoria);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    productos.add(mapearProducto(rs));
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al listar productos por categoría", e);
        }
        
        return productos;
    }
    
    /**
     * Lista productos con stock bajo (menor al umbral especificado).
     * 
     * @param umbral Umbral de stock mínimo
     * @return Lista de productos con stock bajo
     */
    public List<Producto> listarStockBajo(int umbral) {
        List<Producto> productos = new ArrayList<>();
        
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT_STOCK_BAJO)) {
            
            ps.setInt(1, umbral);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    productos.add(mapearProducto(rs));
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al listar productos con stock bajo", e);
        }
        
        return productos;
    }
    
    /**
     * Actualiza un producto existente en la base de datos.
     * 
     * @param producto Objeto Producto con los datos actualizados
     * @return true si la actualización fue exitosa, false en caso contrario
     */
    public boolean actualizar(Producto producto) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE)) {
            
            ps.setString(1, producto.codigo());
            ps.setString(2, producto.nombre());
            ps.setString(3, producto.descripcion());
            ps.setBigDecimal(4, producto.precio());
            ps.setInt(5, producto.stock());
            ps.setString(6, producto.categoria());
            ps.setBoolean(7, producto.estado());
            ps.setInt(8, producto.id());
            
            int filasAfectadas = ps.executeUpdate();
            LOGGER.info("Producto actualizado: " + producto.id() + 
                       " - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al actualizar producto", e);
            return false;
        }
    }
    
    /**
     * Elimina un producto de la base de datos.
     * 
     * @param id ID del producto a eliminar
     * @return true si la eliminación fue exitosa, false en caso contrario
     */
    public boolean eliminar(int id) {
        try (Connection conn = ConexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement(SQL_DELETE)) {
            
            ps.setInt(1, id);
            
            int filasAfectadas = ps.executeUpdate();
            LOGGER.info("Producto eliminado: " + id + " - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al eliminar producto: " + id, e);
            return false;
        }
    }
    
    /**
     * Mapea un ResultSet a un objeto Producto.
     * 
     * @param rs ResultSet posicionado en la fila a mapear
     * @return Objeto Producto con los datos del ResultSet
     * @throws SQLException si hay error en el acceso a datos
     */
    private Producto mapearProducto(ResultSet rs) throws SQLException {
        LocalDateTime fechaRegistro = null;
        Timestamp timestampRegistro = rs.getTimestamp("fecha_registro");
        if (timestampRegistro != null) {
            fechaRegistro = timestampRegistro.toLocalDateTime();
        }
        
        LocalDateTime fechaActualizacion = null;
        Timestamp timestampActualizacion = rs.getTimestamp("fecha_actualizacion");
        if (timestampActualizacion != null) {
            fechaActualizacion = timestampActualizacion.toLocalDateTime();
        }
        
        return new Producto(
            rs.getInt("id"),
            rs.getString("codigo"),
            rs.getString("nombre"),
            rs.getString("descripcion"),
            rs.getBigDecimal("precio"),
            rs.getInt("stock"),
            rs.getString("categoria"),
            rs.getBoolean("estado"),
            fechaRegistro,
            fechaActualizacion
        );
    }
}
