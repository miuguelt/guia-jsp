import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inventario/models/usuario.dart';

void main() {
  group('Rol - fromJson', () {
    test('construye Rol con todos los campos', () {
      final json = <String, dynamic>{
        'id': 1,
        'nombre': 'Administrador',
        'descripcion': 'Acceso total',
        'estado': true,
        'fecha_creacion': '2024-01-01T00:00:00.000',
      };
      final rol = Rol.fromJson(json);
      expect(rol.id, 1);
      expect(rol.nombre, 'Administrador');
      expect(rol.descripcion, 'Acceso total');
      expect(rol.estado, isTrue);
      expect(rol.fechaCreacion, DateTime(2024, 1, 1));
    });

    test('asigna valores por defecto cuando faltan campos opcionales', () {
      final json = <String, dynamic>{
        'id': 2,
        'nombre': 'Auxiliar',
      };
      final rol = Rol.fromJson(json);
      expect(rol.descripcion, isNull);
      expect(rol.estado, isTrue);
      expect(rol.fechaCreacion, isNull);
    });

    test('lanza TypeError cuando falta campo requerido', () {
      expect(
        () => Rol.fromJson(<String, dynamic>{'id': 1}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('Rol - toJson', () {
    test('serializa campos correctamente', () {
      final rol = Rol(id: 1, nombre: 'Administrador', descripcion: 'Acceso total');
      final json = rol.toJson();
      expect(json['nombre'], 'Administrador');
      expect(json['descripcion'], 'Acceso total');
    });
  });

  group('Rol - toString', () {
    test('incluye id y nombre', () {
      final rol = Rol(id: 1, nombre: 'Administrador');
      expect(rol.toString(), contains('Administrador'));
    });
  });

  group('Usuario - fromJson', () {
    final usuarioJson = <String, dynamic>{
      'id': 1,
      'username': 'admin',
      'nombre_completo': 'Admin Principal',
      'email': 'admin@sena.edu.co',
      'rol_id': 1,
      'estado': true,
      'fecha_creacion': '2024-01-01T00:00:00.000',
      'rol': {
        'id': 1,
        'nombre': 'Administrador',
        'descripcion': 'Acceso total al sistema',
        'estado': true,
        'fecha_creacion': '2024-01-01T00:00:00.000',
      },
    };

    test('construye Usuario con todos los campos incluyendo rol anidado', () {
      final usuario = Usuario.fromJson(usuarioJson);
      expect(usuario.id, 1);
      expect(usuario.username, 'admin');
      expect(usuario.nombreCompleto, 'Admin Principal');
      expect(usuario.email, 'admin@sena.edu.co');
      expect(usuario.rolId, 1);
      expect(usuario.estado, isTrue);
      expect(usuario.fechaCreacion, DateTime(2024, 1, 1));
      expect(usuario.rol, isNotNull);
      expect(usuario.rol!.nombre, 'Administrador');
    });

    test('construye Usuario sin rol anidado', () {
      final jsonSinRol = <String, dynamic>{
        'id': 2,
        'username': 'auxiliar',
        'nombre_completo': 'Auxiliar Bodega',
        'email': 'auxiliar@sena.edu.co',
        'rol_id': 2,
      };
      final usuario = Usuario.fromJson(jsonSinRol);
      expect(usuario.rol, isNull);
      expect(usuario.estado, isTrue);
    });

    test('lanza TypeError cuando falta campo requerido', () {
      expect(
        () => Usuario.fromJson(<String, dynamic>{'id': 1}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('Usuario - toJson', () {
    test('serializa campos correctamente sin incluir rol anidado', () {
      final usuario = Usuario(
        id: 1,
        username: 'admin',
        nombreCompleto: 'Admin Principal',
        email: 'admin@sena.edu.co',
        rolId: 1,
      );
      final json = usuario.toJson();
      expect(json['username'], 'admin');
      expect(json['nombre_completo'], 'Admin Principal');
      expect(json['email'], 'admin@sena.edu.co');
      expect(json['rol_id'], 1);
      expect(json.containsKey('rol'), isFalse);
    });
  });

  group('Usuario - copyWith', () {
    final base = Usuario(
      id: 1,
      username: 'admin',
      nombreCompleto: 'Admin Principal',
      email: 'admin@sena.edu.co',
      rolId: 1,
      estado: true,
      fechaCreacion: DateTime(2024, 1, 1),
      rol: Rol(id: 1, nombre: 'Administrador'),
    );

    test('cambia campos especificados', () {
      final copia = base.copyWith(username: 'admin2', email: 'admin2@test.com');
      expect(copia.id, 1);
      expect(copia.username, 'admin2');
      expect(copia.email, 'admin2@test.com');
      expect(copia.nombreCompleto, base.nombreCompleto);
    });

    test('sin parametros retorna copia identica', () {
      final copia = base.copyWith();
      expect(copia.username, base.username);
      expect(copia.rolId, base.rolId);
      expect(copia.rol?.nombre, base.rol?.nombre);
    });
  });
}
