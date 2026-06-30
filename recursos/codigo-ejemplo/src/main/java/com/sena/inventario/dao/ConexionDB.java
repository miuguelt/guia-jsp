package com.sena.inventario.dao;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Clase utilitaria para gestionar la conexión a la base de datos PostgreSQL.
 * Implementa el patrón Singleton para reutilizar la configuración.
 * 
 * Esta clase lee las credenciales desde el archivo db.properties
 * ubicado en src/main/resources/
 */
public class ConexionDB {
    
    private static final Logger LOGGER = Logger.getLogger(ConexionDB.class.getName());
    private static final Properties PROPIEDADES = new Properties();
    
    // Bloque estático para cargar las propiedades una sola vez
    static {
        cargarPropiedades();
        try {
            // Registrar el driver de PostgreSQL
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Driver PostgreSQL no encontrado", e);
            throw new RuntimeException("Error al cargar el driver de PostgreSQL", e);
        }
    }
    
    /**
     * Carga las propiedades de conexión desde db.properties
     */
    private static void cargarPropiedades() {
        try (InputStream input = ConexionDB.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            if (input == null) {
                LOGGER.warning("Archivo db.properties no encontrado. Usando valores por defecto.");
                PROPIEDADES.setProperty("db.url", "jdbc:postgresql://localhost:5432/inventario_db");
                PROPIEDADES.setProperty("db.username", "postgres");
                PROPIEDADES.setProperty("db.password", "postgres");
                return;
            }
            PROPIEDADES.load(input);
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Error al cargar db.properties", e);
        }
    }
    
    /**
     * Obtiene una conexión a la base de datos.
     * Prioridad de configuración (de mayor a menor):
     *   1. DATABASE_URL (formato: postgresql://user:pass@host:5432/dbname)
     *   2. DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD (env vars individuales)
     *   3. db.properties (archivo de configuración local)
     *
     * @return Connection activa a la base de datos
     * @throws SQLException si hay error en la conexión
     */
    public static Connection conectar() throws SQLException {
        String databaseUrl = System.getenv("DATABASE_URL");
        String url;
        String usuario;
        String password;

        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            // DATABASE_URL: postgresql://user:pass@host:5432/dbname
            String jdbcUrl = databaseUrl.replaceFirst("^postgresql://", "jdbc:postgresql://");
            int atIndex = jdbcUrl.indexOf("@");
            if (atIndex != -1) {
                String credenciales = jdbcUrl.substring("jdbc:postgresql://".length(), atIndex);
                int colonIndex = credenciales.indexOf(":");
                usuario = credenciales.substring(0, colonIndex);
                password = colonIndex != -1 ? credenciales.substring(colonIndex + 1) : "";
                url = "jdbc:postgresql://" + jdbcUrl.substring(atIndex + 1);
            } else {
                url = jdbcUrl;
                usuario = "postgres";
                password = "";
            }
            LOGGER.info("Conectando vía DATABASE_URL");
        } else {
            String host = System.getenv("DB_HOST");
            if (host != null && !host.isEmpty()) {
                // Entorno Docker/Coolify: construir URL desde env vars individuales
                String port = System.getenv("DB_PORT");
                if (port == null || port.isEmpty()) port = "5432";
                String dbName = System.getenv("DB_NAME");
                if (dbName == null || dbName.isEmpty()) dbName = "inventario_db";
                usuario = System.getenv("DB_USER");
                if (usuario == null || usuario.isEmpty()) usuario = "postgres";
                password = System.getenv("DB_PASSWORD");
                if (password == null) password = "";
                url = "jdbc:postgresql://" + host + ":" + port + "/" + dbName;
                LOGGER.info("Conectando vía env vars: " + url);
            } else {
                // Entorno local: leer desde db.properties
                url = PROPIEDADES.getProperty("db.url");
                usuario = PROPIEDADES.getProperty("db.username");
                password = PROPIEDADES.getProperty("db.password");
            }
        }

        Connection conexion = DriverManager.getConnection(url, usuario, password);
        LOGGER.fine("Conexión exitosa a la base de datos");
        return conexion;
    }
    
    /**
     * Obtiene una conexión usando parámetros personalizados.
     * Útil para entornos donde las credenciales vienen de variables de entorno.
     * 
     * @param url      URL de conexión JDBC
     * @param usuario  Nombre de usuario
     * @param password Contraseña
     * @return Connection activa a la base de datos
     * @throws SQLException si hay error en la conexión
     */
    public static Connection conectar(String url, String usuario, String password) 
            throws SQLException {
        return DriverManager.getConnection(url, usuario, password);
    }
    
    /**
     * Obtiene el valor de una propiedad de configuración.
     * 
     * @param clave Nombre de la propiedad
     * @return Valor de la propiedad o null si no existe
     */
    public static String getPropiedad(String clave) {
        return PROPIEDADES.getProperty(clave);
    }
}
