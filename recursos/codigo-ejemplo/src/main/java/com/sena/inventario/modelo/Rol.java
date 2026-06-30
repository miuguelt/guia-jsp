package com.sena.inventario.modelo;

import java.time.LocalDateTime;

/**
 * Record que representa un Rol en el sistema.
 * Los records son una característica de JDK 14+ (estable en JDK 16+)
 * que proporcionan inmutabilidad y métodos automáticos.
 * 
 * @param id          Identificador único del rol
 * @param nombre      Nombre del rol (Administrador, Cliente, Invitado)
 * @param descripcion Descripción del rol
 * @param estado      Estado activo/inactivo del rol
 * @param fechaCreacion Fecha de creación del registro
 */
public record Rol(
    int id,
    String nombre,
    String descripcion,
    boolean estado,
    LocalDateTime fechaCreacion
) {
    /**
     * Constructor alternativo sin id (para inserciones nuevas).
     */
    public Rol(String nombre, String descripcion, boolean estado) {
        this(0, nombre, descripcion, estado, LocalDateTime.now());
    }
    
    /**
     * Constructor alternativo sin id ni fecha.
     */
    public Rol(String nombre, String descripcion) {
        this(0, nombre, descripcion, true, LocalDateTime.now());
    }
}
