import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inventario/core/constants.dart';
import 'package:flutter_inventario/core/network/api_exceptions.dart';
import 'package:flutter_inventario/models/auth_response.dart';
import 'package:flutter_inventario/models/usuario.dart';
import 'package:flutter_inventario/providers/auth_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late AuthNotifier notifier;

  setUp(() {
    mockAuthService = MockAuthService();
    notifier = AuthNotifier(mockAuthService);
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthNotifier - estado inicial', () {
    test('comienza en estado no autenticado', () {
      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.usuario, isNull);
      expect(notifier.state.token, isNull);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });
  });

  group('AuthNotifier - login', () {
    test('actualiza estado a autenticado con token en caso de exito', () async {
      final usuario = Usuario(
        id: 1,
        username: 'admin',
        nombreCompleto: 'Admin Principal',
        email: 'admin@sena.edu.co',
        rolId: 1,
      );
      when(mockAuthService.login('admin', '123456')).thenAnswer(
        (_) async => AuthResponse(
          accessToken: 'token-jwt-test',
          usuario: usuario,
        ),
      );

      await notifier.login('admin', '123456');

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.token, 'token-jwt-test');
      expect(notifier.state.usuario, usuario);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('maneja error sin autenticar al usuario', () async {
      when(mockAuthService.login('admin', 'wrong')).thenThrow(
        ApiException('Credenciales invalidas', statusCode: 401),
      );

      await notifier.login('admin', 'wrong');

      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.error, isNotNull);
    });
  });

  group('AuthNotifier - logout', () {
    test('limpia token y estado al cerrar sesion', () async {
      final usuario = Usuario(
        id: 1,
        username: 'admin',
        nombreCompleto: 'Admin',
        email: 'admin@sena.edu.co',
        rolId: 1,
      );
      when(mockAuthService.login('admin', '123')).thenAnswer(
        (_) async => AuthResponse(accessToken: 'token', usuario: usuario),
      );

      await notifier.login('admin', '123');
      expect(notifier.state.isAuthenticated, isTrue);

      await notifier.logout();

      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.token, isNull);
      expect(notifier.state.usuario, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppConstants.tokenKey), isNull);
      expect(prefs.getString(AppConstants.userKey), isNull);
    });
  });

  group('AuthNotifier - register', () {
    test('crea cuenta e inicia sesion automaticamente', () async {
      final usuario = Usuario(
        id: 1,
        username: 'nuevo',
        nombreCompleto: 'Nuevo Usuario',
        email: 'nuevo@sena.edu.co',
        rolId: 2,
      );
      when(mockAuthService.register(
        'nuevo', 'password123', 'Nuevo Usuario', 'nuevo@sena.edu.co', 2,
      )).thenAnswer((_) async => usuario);

      when(mockAuthService.login('nuevo', 'password123')).thenAnswer(
        (_) async => AuthResponse(
          accessToken: 'new-token',
          usuario: usuario,
        ),
      );

      await notifier.register(
        'nuevo', 'password123', 'Nuevo Usuario', 'nuevo@sena.edu.co', 2,
      );

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.token, 'new-token');
      expect(notifier.state.usuario?.username, 'nuevo');
    });

    test('maneja error de registro', () async {
      when(mockAuthService.register(
        'x', 'x', 'x', 'x@x.com', 1,
      )).thenThrow(ApiException('Error al registrar'));

      await notifier.register('x', 'x', 'x', 'x@x.com', 1);

      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.error, isNotNull);
    });
  });

  group('AuthNotifier - checkAuth', () {
    test('permanece no autenticado sin token guardado', () async {
      await notifier.checkAuth();

      expect(notifier.state.isAuthenticated, isFalse);
    });

    test('restaura sesion con token valido', () async {
      final usuario = Usuario(
        id: 1,
        username: 'admin',
        nombreCompleto: 'Admin',
        email: 'admin@sena.edu.co',
        rolId: 1,
      );
      SharedPreferences.setMockInitialValues({
        AppConstants.tokenKey: 'valid-token',
        AppConstants.userKey: jsonEncode(usuario.toJson()),
      });
      when(mockAuthService.getProfile()).thenAnswer((_) async => usuario);

      await notifier.checkAuth();

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.token, 'valid-token');
      expect(notifier.state.usuario, usuario);
    });

    test('limpia sesion con token invalido', () async {
      final usuario = Usuario(
        id: 1,
        username: 'admin',
        nombreCompleto: 'Admin',
        email: 'admin@sena.edu.co',
        rolId: 1,
      );
      SharedPreferences.setMockInitialValues({
        AppConstants.tokenKey: 'invalid-token',
        AppConstants.userKey: jsonEncode(usuario.toJson()),
      });
      when(mockAuthService.getProfile()).thenThrow(
        ApiException('Token invalido', statusCode: 401),
      );

      await notifier.checkAuth();

      expect(notifier.state.isAuthenticated, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppConstants.tokenKey), isNull);
      expect(prefs.getString(AppConstants.userKey), isNull);
    });
  });
}
