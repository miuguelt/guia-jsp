import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inventario/models/auth_response.dart';
import 'package:flutter_inventario/models/usuario.dart';

void main() {
  group('AuthResponse - fromJson', () {
    test('construye AuthResponse con token, token_type y usuario', () {
      final json = <String, dynamic>{
        'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.token',
        'token_type': 'bearer',
        'usuario': {
          'id': 1,
          'username': 'admin',
          'nombre_completo': 'Admin Principal',
          'email': 'admin@sena.edu.co',
          'rol_id': 1,
          'estado': true,
        },
      };
      final response = AuthResponse.fromJson(json);
      expect(response.accessToken, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.token');
      expect(response.tokenType, 'bearer');
      expect(response.usuario, isA<Usuario>());
      expect(response.usuario.username, 'admin');
    });

    test('asigna token_type por defecto "bearer" cuando no esta presente', () {
      final json = <String, dynamic>{
        'access_token': 'token-sin-tipo',
        'usuario': {
          'id': 2,
          'username': 'auxiliar',
          'nombre_completo': 'Auxiliar',
          'email': 'auxiliar@sena.edu.co',
          'rol_id': 2,
        },
      };
      final response = AuthResponse.fromJson(json);
      expect(response.tokenType, 'bearer');
    });

    test('lanza TypeError cuando falta access_token', () {
      final json = <String, dynamic>{
        'usuario': {
          'id': 1,
          'username': 'admin',
          'nombre_completo': 'Admin',
          'email': 'admin@sena.edu.co',
          'rol_id': 1,
        },
      };
      expect(() => AuthResponse.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('lanza TypeError cuando falta usuario', () {
      final json = <String, dynamic>{
        'access_token': 'token-sin-usuario',
      };
      expect(() => AuthResponse.fromJson(json), throwsA(isA<TypeError>()));
    });
  });

  group('AuthResponse - toJson', () {
    test('serializa a mapa con access_token, token_type y usuario', () {
      final usuario = Usuario(
        id: 1,
        username: 'admin',
        nombreCompleto: 'Admin Principal',
        email: 'admin@sena.edu.co',
        rolId: 1,
      );
      final response = AuthResponse(
        accessToken: 'test-token',
        tokenType: 'bearer',
        usuario: usuario,
      );
      final json = response.toJson();
      expect(json['access_token'], 'test-token');
      expect(json['token_type'], 'bearer');
      expect(json['usuario'], isA<Map<String, dynamic>>());
      expect(json['usuario']['username'], 'admin');
    });
  });

  group('AuthResponse - toString', () {
    test('incluye username del usuario', () {
      final usuario = Usuario(
        id: 1,
        username: 'admin',
        nombreCompleto: 'Admin',
        email: 'admin@sena.edu.co',
        rolId: 1,
      );
      final response = AuthResponse(
        accessToken: 'token',
        usuario: usuario,
      );
      expect(response.toString(), contains('admin'));
    });
  });
}
