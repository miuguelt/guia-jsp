// =============================================================================
//  Modelo: Producto
//  Representa un producto del inventario.
//  Incluye serializacion JSON para comunicación con la API.
// =============================================================================

class Producto {
  final int id;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int stock;
  final String? categoria;
  final bool estado;
  final int? usuarioCreadorId;
  final DateTime? fechaRegistro;

  const Producto({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.stock,
    this.categoria,
    this.estado = true,
    this.usuarioCreadorId,
    this.fechaRegistro,
  });

  /// Construye un [Producto] desde un mapa JSON (respuesta de la API).
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      precio: (json['precio'] as num).toDouble(),
      stock: json['stock'] as int,
      categoria: json['categoria'] as String?,
      estado: json['estado'] as bool? ?? true,
      usuarioCreadorId: json['usuario_creador_id'] as int?,
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'] as String)
          : null,
    );
  }

  /// Convierte el [Producto] a un mapa JSON para enviar a la API.
  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'categoria': categoria,
    };
  }

  /// Crea una copia del producto con campos opcionalmente modificados.
  Producto copyWith({
    int? id,
    String? codigo,
    String? nombre,
    String? descripcion,
    double? precio,
    int? stock,
    String? categoria,
    bool? estado,
    int? usuarioCreadorId,
    DateTime? fechaRegistro,
  }) {
    return Producto(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      categoria: categoria ?? this.categoria,
      estado: estado ?? this.estado,
      usuarioCreadorId: usuarioCreadorId ?? this.usuarioCreadorId,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  String toString() => 'Producto(id: $id, codigo: $codigo, nombre: $nombre)';
}

/// Respuesta paginada de la API para listas de productos.
///
/// La API retorna:
/// ```json
/// { "items": [...], "total": 100, "pagina": 1, "tamano": 10, "total_paginas": 10 }
/// ```
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int pagina;
  final int tamano;
  final int totalPaginas;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.pagina,
    required this.tamano,
    required this.totalPaginas,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItemJson,
  ) {
    return PaginatedResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => fromItemJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      pagina: json['pagina'] as int,
      tamano: json['tamano'] as int,
      totalPaginas: json['total_paginas'] as int,
    );
  }
}
