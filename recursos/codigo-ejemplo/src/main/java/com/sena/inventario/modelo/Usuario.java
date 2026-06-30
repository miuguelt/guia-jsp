package com.sena.inventario.modelo;

import java.time.LocalDateTime;

/**
 * Record que representa un Usuario en el sistema.
 * Utiliza las ventajas de los records de JDK 21 para
 * inmutabilidad y generación automática de métodos.
 * 
 * @param id              Identificador único del usuario
 * @param username        Nombre de usuario para login
 * @param password        Contraseña encriptada (BCrypt)
 * @param nombreCompleto  Nombre completo del usuario
 * @param email           Correo electrónico del usuario
 * @param rolId           ID del rol asignado al usuario
 * @param estado          Estado activo/inactivo del usuario
 * @param fechaCreacion   Fecha de creación del usuario
 * @param ultimoAcceso    Fecha y hora del último acceso
 */
public record Usuario(
    int id,
    String username,
    String password,
    String nombreCompleto,
    String email,
    int rolId,
    boolean estado,
    LocalDateTime fechaCreacion,
    LocalDateTime ultimoAcceso
) {
    /**
     * Constructor para crear un nuevo usuario (sin id ni fechas automáticas).
     */
    public Usuario(String username, String password, String nombreCompleto, 
                   String email, int rolId) {
        this(0, username, password, nombreCompleto, email, rolId, 
             true, LocalDateTime.now(), null);
    }
    
    /**
     * Constructor simplificado para formularios de edición.
     */
    public Usuario(int id, String username, String nombreCompleto, 
                   String email, int rolId, boolean estado) {
        this(id, username, "", nombreCompleto, email, rolId, 
             estado, null, null);
    }
}
