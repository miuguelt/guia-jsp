package com.sena.inventario.util;

import at.favre.lib.crypto.bcrypt.BCrypt;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Clase utilitaria para la encriptación y verificación de contraseñas
 * usando el algoritmo BCrypt.
 * 
 * BCrypt es un algoritmo de hash diseñado específicamente para contraseñas.
 * Incluye un "salt" automático y es resistente a ataques de fuerza bruta.
 */
public class PasswordUtil {
    
    private static final Logger LOGGER = Logger.getLogger(PasswordUtil.class.getName());
    
    // Costo del algoritmo BCrypt (mayor = más lento pero más seguro)
    // 10 es el valor recomendado por defecto
    private static final int BCRYPT_COST = 10;
    
    /**
     * Encripta una contraseña en texto plano usando BCrypt.
     * 
     * @param password Texto plano a encriptar
     * @return Hash BCrypt de la contraseña
     */
    public static String encriptar(String password) {
        try {
            return BCrypt.withDefaults().hashToString(BCRYPT_COST, password.toCharArray());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error al encriptar contraseña", e);
            throw new RuntimeException("Error al encriptar contraseña", e);
        }
    }
    
    /**
     * Verifica si una contraseña en texto plano coincide con un hash BCrypt.
     * 
     * @param password Texto plano a verificar
     * @param hash Hash BCrypt contra el cual comparar
     * @return true si la contraseña coincide, false en caso contrario
     */
    public static boolean verificar(String password, String hash) {
        try {
            BCrypt.Result result = BCrypt.verifyer().verify(password.toCharArray(), hash);
            return result.verified;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error al verificar contraseña", e);
            return false;
        }
    }
    
    /**
     * Genera una contraseña aleatoria de la longitud especificada.
     * Útil para restablecer contraseñas.
     * 
     * @param longitud Longitud de la contraseña (mínimo 8)
     * @return Contraseña aleatoria
     */
    public static String generarPasswordAleatoria(int longitud) {
        if (longitud < 8) {
            longitud = 8;
        }
        
        String caracteres = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%";
        StringBuilder password = new StringBuilder();
        
        // Usar SecureRandom para mayor seguridad
        java.security.SecureRandom random = new java.security.SecureRandom();
        for (int i = 0; i < longitud; i++) {
            password.append(caracteres.charAt(random.nextInt(caracteres.length())));
        }
        
        return password.toString();
    }
}
