import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inventario/core/network/api_exceptions.dart';
import 'package:flutter_inventario/models/usuario.dart';
import 'package:flutter_inventario/services/usuario_service.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  late MockDio mockDio;
  late UsuarioService usuarioService;

  setUp(() {
    mockDio = MockDio();
    usuarioService = UsuarioService(mockDio);
  });

  group('UsuarioService - getAll', () {
    test('retorna List<Usuario> en caso de exito', () async {
      final usuariosJson = [
        <String, dynamic>{
          'id': 1,
          'username': 'admin',
          'nombre_completo': 'Admin Principal',
          'email': 'admin@sena.edu.co',
          'rol_id': 1,
          'rol': {
            'id': 1,
            'nombre': 'Administrador',
            'estado': true,
          },
        },
        <String, dynamic>{
          'id': 2,
          'username': 'auxiliar',
          'nombre_completo': 'Auxiliar Bodega',
          'email': 'auxiliar@sena.edu.co',
          'rol_id': 2,
        },
      ];
      when(mockDio.get('/usuarios/')).thenAnswer((_) async => Response(
        data: usuariosJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/usuarios/'),
      ));

      final result = await usuarioService.getAll();

      expect(result, isA<List<Usuario>>());
      expect(result.length, 2);
      expect(result.first.username, 'admin');
      expect(result.first.rol?.nombre, 'Administrador');
    });

    test('lanza ApiException cuando falla', () async {
      when(mockDio.get('/usuarios/')).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/usuarios/'),
      ));

      expect(
        () => usuarioService.getAll(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('UsuarioService - getById', () {
    test('retorna Usuario en caso de exito', () async {
      final usuarioJson = <String, dynamic>{
        'id': 1,
        'username': 'admin',
        'nombre_completo': 'Admin Principal',
        'email': 'admin@sena.edu.co',
        'rol_id': 1,
        'estado': true,
      };
      when(mockDio.get('/usuarios/1')).thenAnswer((_) async => Response(
        data: usuarioJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/usuarios/1'),
      ));

      final result = await usuarioService.getById(1);

      expect(result, isA<Usuario>());
      expect(result.username, 'admin');
    });

    test('lanza ApiException cuando falla', () async {
      when(mockDio.get('/usuarios/1')).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/usuarios/1'),
      ));

      expect(
        () => usuarioService.getById(1),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('UsuarioService - create', () {
    test('retorna Usuario creado en caso de exito', () async {
      final data = <String, dynamic>{
        'username': 'nuevo',
        'nombre_completo': 'Nuevo Usuario',
        'email': 'nuevo@sena.edu.co',
        'rol_id': 2,
      };
      final createdJson = <String, dynamic>{
        'id': 3,
        'username': 'nuevo',
        'nombre_completo': 'Nuevo Usuario',
        'email': 'nuevo@sena.edu.co',
        'rol_id': 2,
        'estado': true,
      };
      when(mockDio.post(
        '/auth/register',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
        data: createdJson,
        statusCode: 201,
        requestOptions: RequestOptions(path: '/auth/register'),
      ));

      final result = await usuarioService.create(data);

      expect(result, isA<Usuario>());
      expect(result.username, 'nuevo');
    });

    test('lanza ApiException cuando falla', () async {
      when(mockDio.post(
        '/auth/register',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
      ));

      expect(
        () => usuarioService.create(<String, dynamic>{}),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('UsuarioService - update', () {
    test('retorna Usuario actualizado en caso de exito', () async {
      final data = <String, dynamic>{
        'nombre_completo': 'Admin Modificado',
      };
      final updatedJson = <String, dynamic>{
        'id': 1,
        'username': 'admin',
        'nombre_completo': 'Admin Modificado',
        'email': 'admin@sena.edu.co',
        'rol_id': 1,
        'estado': true,
      };
      when(mockDio.put(
        '/usuarios/1',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
        data: updatedJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/usuarios/1'),
      ));

      final result = await usuarioService.update(1, data);

      expect(result, isA<Usuario>());
      expect(result.nombreCompleto, 'Admin Modificado');
    });

    test('lanza ApiException cuando falla', () async {
      when(mockDio.put(
        '/usuarios/1',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/usuarios/1'),
      ));

      expect(
        () => usuarioService.update(1, <String, dynamic>{}),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
