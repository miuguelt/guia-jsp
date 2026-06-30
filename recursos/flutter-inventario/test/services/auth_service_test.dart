import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inventario/core/network/api_exceptions.dart';
import 'package:flutter_inventario/models/auth_response.dart';
import 'package:flutter_inventario/models/usuario.dart';
import 'package:flutter_inventario/services/auth_service.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  late MockDio mockDio;
  late AuthService authService;

  setUp(() {
    mockDio = MockDio();
    authService = AuthService(mockDio);
  });

  group('AuthService - login', () {
    const username = 'admin';
    const password = '123456';

    test('retorna AuthResponse en caso de exito', () async {
      final usuarioJson = <String, dynamic>{
        'id': 1,
        'username': 'admin',
        'nombre_completo': 'Admin Principal',
        'email': 'admin@sena.edu.co',
        'rol_id': 1,
        'estado': true,
      };
      final authResponseJson = <String, dynamic>{
        'access_token': 'eyJhbGciOiJIUzI1NiJ9.token',
        'token_type': 'bearer',
        'usuario': usuarioJson,
      };
      when(mockDio.post(
        '/auth/login',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
        data: authResponseJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/login'),
      ));

      final result = await authService.login(username, password);

      expect(result, isA<AuthResponse>());
      expect(result.accessToken, 'eyJhbGciOiJIUzI1NiJ9.token');
      expect(result.usuario.username, 'admin');
      expect(result.tokenType, 'bearer');
    });

    test('lanza ApiException cuando Dio falla con error 401', () async {
      when(mockDio.post(
        '/auth/login',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
      ));

      expect(
        () => authService.login(username, 'wrong'),
        throwsA(isA<ApiException>()),
      );
    });

    test('re-lanza ApiException cuando el error ya es ApiException', () async {
      when(mockDio.post(
        '/auth/login',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        error: ApiException('Credenciales invalidas', statusCode: 401),
      ));

      expect(
        () => authService.login(username, 'wrong'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('AuthService - register', () {
    test('retorna Usuario en caso de exito', () async {
      final usuarioJson = <String, dynamic>{
        'id': 2,
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
        data: usuarioJson,
        statusCode: 201,
        requestOptions: RequestOptions(path: '/auth/register'),
      ));

      final result = await authService.register(
        'nuevo', 'password123', 'Nuevo Usuario', 'nuevo@sena.edu.co', 2,
      );

      expect(result, isA<Usuario>());
      expect(result.username, 'nuevo');
      expect(result.nombreCompleto, 'Nuevo Usuario');
    });

    test('lanza ApiException cuando falla', () async {
      when(mockDio.post(
        '/auth/register',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
      ));

      expect(
        () => authService.register('x', 'x', 'x', 'x@x.com', 1),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('AuthService - getProfile', () {
    test('retorna Usuario en caso de exito', () async {
      final usuarioJson = <String, dynamic>{
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
      };
      when(mockDio.get('/auth/me')).thenAnswer((_) async => Response(
        data: usuarioJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/me'),
      ));

      final result = await authService.getProfile();

      expect(result, isA<Usuario>());
      expect(result.username, 'admin');
      expect(result.rol?.nombre, 'Administrador');
    });

    test('lanza ApiException cuando falla', () async {
      when(mockDio.get('/auth/me')).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/auth/me'),
        ),
      ));

      expect(
        () => authService.getProfile(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('AuthService - getRoles', () {
    test('retorna lista de roles en caso de exito', () async {
      final rolesJson = [
        <String, dynamic>{
          'id': 1,
          'nombre': 'Administrador',
          'estado': true,
        },
        <String, dynamic>{
          'id': 2,
          'nombre': 'Auxiliar de Bodega',
          'estado': true,
        },
      ];
      when(mockDio.get('/roles/')).thenAnswer((_) async => Response(
        data: rolesJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/roles/'),
      ));

      final result = await authService.getRoles();

      expect(result, isA<List<Rol>>());
      expect(result.length, 2);
      expect(result.first.nombre, 'Administrador');
    });

    test('lanza ApiException cuando falla', () async {
      when(mockDio.get('/roles/')).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/roles/'),
      ));

      expect(
        () => authService.getRoles(),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
