import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inventario/models/producto.dart';

void main() {
  group('Producto - fromJson', () {
    final jsonCompleto = <String, dynamic>{
      'id': 1,
      'codigo': 'PROD-001',
      'nombre': 'Laptop Gamer',
      'descripcion': 'Laptop de alta gama para gaming',
      'precio': 4999.99,
      'stock': 10,
      'categoria': 'Electronica',
      'estado': true,
      'usuario_creador_id': 1,
      'fecha_registro': '2024-01-15T10:30:00.000',
    };

    test('construye Producto con todos los campos', () {
      final producto = Producto.fromJson(jsonCompleto);
      expect(producto.id, 1);
      expect(producto.codigo, 'PROD-001');
      expect(producto.nombre, 'Laptop Gamer');
      expect(producto.descripcion, 'Laptop de alta gama para gaming');
      expect(producto.precio, 4999.99);
      expect(producto.stock, 10);
      expect(producto.categoria, 'Electronica');
      expect(producto.estado, isTrue);
      expect(producto.usuarioCreadorId, 1);
      expect(producto.fechaRegistro, DateTime(2024, 1, 15, 10, 30));
    });

    test('asigna null a campos opcionales ausentes', () {
      final minimo = <String, dynamic>{
        'id': 2,
        'codigo': 'PROD-002',
        'nombre': 'Mouse',
        'precio': 49.99,
        'stock': 100,
      };
      final producto = Producto.fromJson(minimo);
      expect(producto.descripcion, isNull);
      expect(producto.categoria, isNull);
      expect(producto.usuarioCreadorId, isNull);
      expect(producto.fechaRegistro, isNull);
      expect(producto.estado, isTrue);
    });

    test('lanza TypeError cuando falta campo requerido', () {
      final incompleto = <String, dynamic>{'id': 1, 'codigo': 'PROD-001'};
      expect(() => Producto.fromJson(incompleto), throwsA(isA<TypeError>()));
    });

    test('lanza TypeError con id nulo', () {
      final json = <String, dynamic>{
        'id': null,
        'codigo': 'PROD-001',
        'nombre': 'Test',
        'precio': 10.0,
        'stock': 5,
      };
      expect(() => Producto.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('convierte precio desde entero a double', () {
      final json = <String, dynamic>{
        'id': 3,
        'codigo': 'PROD-003',
        'nombre': 'Teclado',
        'precio': 79,
        'stock': 50,
      };
      final producto = Producto.fromJson(json);
      expect(producto.precio, isA<double>());
      expect(producto.precio, 79.0);
    });

    test('parsea fechaRegistro correctamente', () {
      final json = <String, dynamic>{
        'id': 4,
        'codigo': 'PROD-004',
        'nombre': 'Monitor',
        'precio': 299.99,
        'stock': 20,
        'fecha_registro': '2024-06-01T08:00:00.000Z',
      };
      final producto = Producto.fromJson(json);
      expect(producto.fechaRegistro, DateTime(2024, 6, 1, 8, 0));
    });
  });

  group('Producto - toJson', () {
    test('serializa campos correctamente', () {
      final producto = Producto(
        id: 1,
        codigo: 'PROD-001',
        nombre: 'Laptop Gamer',
        descripcion: 'Descripcion',
        precio: 4999.99,
        stock: 10,
        categoria: 'Electronica',
      );
      final json = producto.toJson();
      expect(json['codigo'], 'PROD-001');
      expect(json['nombre'], 'Laptop Gamer');
      expect(json['descripcion'], 'Descripcion');
      expect(json['precio'], 4999.99);
      expect(json['stock'], 10);
      expect(json['categoria'], 'Electronica');
    });

    test('serializa con campos opcionales nulos', () {
      final producto = Producto(
        id: 2,
        codigo: 'PROD-002',
        nombre: 'Mouse',
        precio: 49.99,
        stock: 100,
      );
      final json = producto.toJson();
      expect(json['descripcion'], isNull);
      expect(json['categoria'], isNull);
    });

    test('round-trip fromJson -> toJson mantiene campos de envio', () {
      final original = Producto(
        id: 1,
        codigo: 'COD-001',
        nombre: 'Producto X',
        precio: 100.0,
        stock: 5,
      );
      final json = original.toJson();
      final recreado = Producto.fromJson({
        ...json,
        'id': original.id,
      });
      expect(recreado.codigo, original.codigo);
      expect(recreado.nombre, original.nombre);
      expect(recreado.precio, original.precio);
      expect(recreado.stock, original.stock);
    });
  });

  group('Producto - copyWith', () {
    final base = Producto(
      id: 1,
      codigo: 'PROD-001',
      nombre: 'Laptop Gamer',
      descripcion: 'Original',
      precio: 4999.99,
      stock: 10,
      categoria: 'Electronica',
      estado: true,
      usuarioCreadorId: 1,
      fechaRegistro: DateTime(2024, 1, 15),
    );

    test('cambia campos especificados', () {
      final copia = base.copyWith(nombre: 'Laptop Oficina', precio: 3999.99);
      expect(copia.id, base.id);
      expect(copia.nombre, 'Laptop Oficina');
      expect(copia.precio, 3999.99);
      expect(copia.codigo, base.codigo);
      expect(copia.descripcion, base.descripcion);
    });

    test('sin parametros retorna copia identica', () {
      final copia = base.copyWith();
      expect(copia.id, base.id);
      expect(copia.nombre, base.nombre);
      expect(copia.precio, base.precio);
    });

    test('cambia campos opcionales nulos', () {
      final sinOpcionales = Producto(
        id: 2, codigo: 'P002', nombre: 'Test', precio: 10.0, stock: 1,
      );
      final copia = sinOpcionales.copyWith(
        descripcion: 'Nueva desc',
        categoria: 'Nueva cat',
      );
      expect(copia.descripcion, 'Nueva desc');
      expect(copia.categoria, 'Nueva cat');
    });

    test('cambia boolean estado', () {
      final copia = base.copyWith(estado: false);
      expect(copia.estado, isFalse);
    });
  });
}
