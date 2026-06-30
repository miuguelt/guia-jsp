package com.sena.inventario.modelo;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Record que representa un Producto en el inventario.
 * Implementa las mejores prácticas de JDK 21 con records
 * para garantizar inmutabilidad y código limpio.
 * 
 * @param id                Identificador único del producto
 * @param codigo            Código único del producto (ej: PROD-001)
 * @param nombre            Nombre del producto
 * @param descripcion       Descripción detallada del producto
 * @param precio            Precio unitario del producto
 * @param stock             Cantidad disponible en inventario
 * @param categoria         Categoría del producto
 * @param estado            Estado activo/inactivo del producto
 * @param fechaRegistro     Fecha de registro del producto
 * @param fechaActualizacion Fecha de última actualización
 */
public record Producto(
    int id,
    String codigo,
    String nombre,
    String descripcion,
    BigDecimal precio,
    int stock,
    String categoria,
    boolean estado,
    LocalDateTime fechaRegistro,
    LocalDateTime fechaActualizacion
) {
    /**
     * Constructor para crear un nuevo producto (sin id ni fechas automáticas).
     */
    public Producto(String codigo, String nombre, String descripcion, 
                    BigDecimal precio, int stock, String categoria) {
        this(0, codigo, nombre, descripcion, precio, stock, categoria, 
             true, LocalDateTime.now(), LocalDateTime.now());
    }
    
    /**
     * Constructor simplificado para formularios de edición.
     */
    public Producto(int id, String codigo, String nombre, String descripcion, 
                    BigDecimal precio, int stock, String categoria, boolean estado) {
        this(id, codigo, nombre, descripcion, precio, stock, categoria, 
             estado, null, null);
    }
}
