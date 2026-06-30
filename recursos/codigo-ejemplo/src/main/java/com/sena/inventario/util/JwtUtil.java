package com.sena.inventario.util;

import java.security.Key;
import java.util.Date;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

/**
 * Utilidad para generar y validar tokens JWT.
 * 
 * PUENTE entre el monolito JSP y los microservicios FastAPI:
 * - JSP usa HttpSession (stateful, servidor guarda la sesión)
 * - FastAPI usa JWT (stateless, el token guarda la info)
 * 
 * Esta clase muestra cómo generar el mismo tipo de token JWT
 * que FastAPI, permitiendo que el frontend React use el mismo
 * token sin importar qué backend lo generó.
 * 
 * Dependencia Maven (agregar a pom.xml):
 * <dependency>
 *     <groupId>io.jsonwebtoken</groupId>
 *     <artifactId>jjwt-api</artifactId>
 *     <version>0.12.6</version>
 * </dependency>
 * <dependency>
 *     <groupId>io.jsonwebtoken</groupId>
 *     <artifactId>jjwt-impl</artifactId>
 *     <version>0.12.6</version>
 *     <scope>runtime</scope>
 * </dependency>
 * <dependency>
 *     <groupId>io.jsonwebtoken</groupId>
 *     <artifactId>jjwt-jackson</artifactId>
 *     <version>0.12.6</version>
 *     <scope>runtime</scope>
 * </dependency>
 */
public class JwtUtil {

    // Misma SECRET_KEY que en FastAPI config.py
    // En producción: leer de variable de entorno
    private static final String SECRET_KEY = "sena-adso-jwt-secret-key-2026-cambiar-en-produccion";
    private static final long EXPIRATION_MS = 3_600_000; // 1 hora

    private static Key getSigningKey() {
        return Keys.hmacShaKeyFor(SECRET_KEY.getBytes());
    }

    /**
     * Genera un token JWT (mismo formato que FastAPI).
     *
     * @param username Nombre de usuario (sub del token)
     * @param rol      Nombre del rol (Admin, Cliente, etc.)
     * @return Token JWT como String
     */
    public static String generarToken(String username, String rol) {
        return Jwts.builder()
                .subject(username)
                .claim("rol", rol)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + EXPIRATION_MS))
                .signWith(getSigningKey())
                .compact();
    }

    /**
     * Valida y extrae el username de un token JWT.
     *
     * @param token Token JWT
     * @return username si es válido, null si expiró o es inválido
     */
    public static String validarToken(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            return claims.getSubject();
        } catch (Exception e) {
            return null; // Token inválido o expirado
        }
    }

    /**
     * Extrae el rol del token JWT.
     */
    public static String obtenerRol(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            return claims.get("rol", String.class);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Verifica si un token ha expirado.
     */
    public static boolean estaExpirado(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            return claims.getExpiration().before(new Date());
        } catch (Exception e) {
            return true;
        }
    }

    // ================================================================
    // Ejemplo de uso (main)
    // ================================================================
    public static void main(String[] args) {
        // 1. Generar token (como FastAPI en /api/auth/login)
        String token = generarToken("admin", "Administrador");
        System.out.println("=== TOKEN GENERADO (JWT) ===");
        System.out.println(token);
        System.out.println();

        // 2. Validar token
        String username = validarToken(token);
        System.out.println("=== VALIDACIÓN ===");
        System.out.println("Username: " + username);
        System.out.println("Rol: " + obtenerRol(token));
        System.out.println("Expirado: " + estaExpirado(token));
        System.out.println();

        // 3. Este mismo token puede ser usado por React:
        //    Authorization: Bearer <token>
        //    Así React puede autenticarse tanto contra JSP como contra FastAPI
        System.out.println("=== USO EN REACT ===");
        System.out.println("Authorization: Bearer " + token.substring(0, 50) + "...");
    }
}
