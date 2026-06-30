// =============================================================================
//  Modelos: Rol y Usuario
//  Representan los roles y usuarios del sistema.
// =============================================================================

/// Modelo de Rol (ej: Administrador, Auxiliar de Bodega, Consultor).
class Rol {
  final int id;
  final String nombre;
  final String? descripcion;
  final bool estado;
  final DateTime? fechaCreacion;

  const Rol({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.estado = true,
    this.fechaCreacion,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      estado: json['estado'] as bool? ?? true,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  @override
  String toString() => 'Rol(id: $id, nombre: $nombre)';
}

/// Modelo de Usuario con su relacion de rol incluida.
class Usuario {
  final int id;
  final String username;
  final String nombreCompleto;
  final String email;
  final int rolId;
  final bool estado;
  final DateTime? fechaCreacion;
  final Rol? rol;

  const Usuario({
    required this.id,
    required this.username,
    required this.nombreCompleto,
    required this.email,
    required this.rolId,
    this.estado = true,
    this.fechaCreacion,
    this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      username: json['username'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      email: json['email'] as String,
      rolId: json['rol_id'] as int,
      estado: json['estado'] as bool? ?? true,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
      rol: json['rol'] != null
          ? Rol.fromJson(json['rol'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'nombre_completo': nombreCompleto,
      'email': email,
      'rol_id': rolId,
    };
  }

  Usuario copyWith({
    int? id,
    String? username,
    String? nombreCompleto,
    String? email,
    int? rolId,
    bool? estado,
    DateTime? fechaCreacion,
    Rol? rol,
  }) {
    return Usuario(
      id: id ?? this.id,
      username: username ?? this.username,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      email: email ?? this.email,
      rolId: rolId ?? this.rolId,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      rol: rol ?? this.rol,
    );
  }

  @override
  String toString() => 'Usuario(id: $id, username: $username, rol: ${rol?.nombre})';
}
