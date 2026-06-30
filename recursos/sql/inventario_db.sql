-- ============================================
-- SCRIPT DE BASE DE DATOS - SISTEMA DE INVENTARIO
-- Motor: PostgreSQL 12+
-- Autor: SENA ADSO
-- Descripción: Script para crear las tablas del
-- sistema de inventario con roles, usuarios y productos
-- ============================================

-- Eliminar tablas si existen (en orden inverso por dependencias)
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

-- ============================================
-- TABLA: roles
-- Descripción: Almacena los roles del sistema
-- ============================================
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    estado BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar roles iniciales
INSERT INTO roles (nombre, descripcion) VALUES
('Administrador', 'Acceso completo al sistema'),
('Cliente', 'Acceso limitado para consultas'),
('Invitado', 'Acceso de solo lectura');

-- ============================================
-- TABLA: usuarios
-- Descripción: Almacena los usuarios del sistema
-- ============================================
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    rol_id INTEGER NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP,
    CONSTRAINT fk_usuarios_roles FOREIGN KEY (rol_id) 
        REFERENCES roles(id) ON DELETE RESTRICT
);

-- Insertar usuarios iniciales
-- Password: admin123 (hash BCrypt simplificado para ejemplo)
INSERT INTO usuarios (username, password, nombre_completo, email, rol_id) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Administrador del Sistema', 'admin@sena.edu.co', 1),
('cliente1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Juan Pérez', 'juan@sena.edu.co', 2),
('invitado', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Usuario Invitado', 'invitado@sena.edu.co', 3);

-- ============================================
-- TABLA: productos
-- Descripción: Almacena los productos del inventario
-- ============================================
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    categoria VARCHAR(50),
    estado BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar productos de ejemplo
INSERT INTO productos (codigo, nombre, descripcion, precio, stock, categoria) VALUES
('PROD-001', 'Laptop HP Pavilion', 'Laptop HP Pavilion 15.6" Intel Core i5 8GB RAM', 2500000.00, 15, 'Tecnología'),
('PROD-002', 'Mouse Logitech M185', 'Mouse inalámbrico Logitech M185', 45000.00, 50, 'Accesorios'),
('PROD-003', 'Teclado Mecánico Redragon', 'Teclado mecánico RGB Redragon K552', 180000.00, 30, 'Accesorios'),
('PROD-004', 'Monitor Samsung 24"', 'Monitor Samsung 24" Full HD IPS', 650000.00, 20, 'Tecnología'),
('PROD-005', 'Audífonos Sony WH-1000XM4', 'Audífonos Sony con cancelación de ruido', 1200000.00, 25, 'Audio'),
('PROD-006', 'Disco SSD Kingston 480GB', 'Disco estado sólido Kingston 480GB SATA', 220000.00, 40, 'Almacenamiento'),
('PROD-007', 'Webcam Logitech C920', 'Webcam Logitech C920 Full HD 1080p', 320000.00, 18, 'Accesorios'),
('PROD-008', 'Impresora HP LaserJet', 'Impresora láser HP LaserJet Pro M404n', 850000.00, 10, 'Impresión');

-- ============================================
-- ÍNDICES para mejorar rendimiento
-- ============================================
CREATE INDEX idx_usuarios_username ON usuarios(username);
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_rol ON usuarios(rol_id);
CREATE INDEX idx_productos_codigo ON productos(codigo);
CREATE INDEX idx_productos_categoria ON productos(categoria);
CREATE INDEX idx_productos_estado ON productos(estado);

-- ============================================
-- VISTA: Vista de usuarios con rol
-- ============================================
CREATE OR REPLACE VIEW vista_usuarios_roles AS
SELECT 
    u.id,
    u.username,
    u.nombre_completo,
    u.email,
    r.nombre AS rol_nombre,
    u.estado,
    u.fecha_creacion
FROM usuarios u
INNER JOIN roles r ON u.rol_id = r.id;

-- ============================================
-- FUNCIÓN: Actualizar fecha de modificación
-- ============================================
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar fecha automáticamente
CREATE TRIGGER trigger_actualizar_fecha_productos
    BEFORE UPDATE ON productos
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_fecha_modificacion();

-- ============================================
-- CONSULTAS DE PRUEBA
-- ============================================
-- Ver todos los usuarios con sus roles
SELECT * FROM vista_usuarios_roles;

-- Ver productos con stock bajo (menor a 15)
SELECT codigo, nombre, stock, precio 
FROM productos 
WHERE stock < 15 AND estado = TRUE
ORDER BY stock ASC;

-- Contar productos por categoría
SELECT categoria, COUNT(*) as total, SUM(stock) as stock_total
FROM productos
WHERE estado = TRUE
GROUP BY categoria
ORDER BY total DESC;
