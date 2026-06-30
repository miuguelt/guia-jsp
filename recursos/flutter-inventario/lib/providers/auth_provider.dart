// =============================================================================
//  Provider: AuthProvider (StateNotifier)
//  Gestiona el estado de autenticacion: login, logout, registro y sesion.
// =============================================================================

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/network/api_client.dart';
import '../models/auth_response.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

// ---------------------------------------------------------------------------
//  Estado de autenticacion
// ---------------------------------------------------------------------------

/// Estado inmutable del modulo de autenticacion.
class AuthState {
  /// Usuario autenticado (null si no hay sesion activa).
  final Usuario? usuario;

  /// Token JWT actual (null si no hay sesion activa).
  final String? token;

  /// Indicador de carga para operaciones asincronas.
  final bool isLoading;

  /// Mensaje de error de la ultima operacion.
  final String? error;

  /// Indica si hay una sesion activa (token + usuario presentes).
  bool get isAuthenticated => token != null && usuario != null;

  /// Indica si el usuario autenticado tiene rol Administrador.
  bool get isAdmin => usuario?.rol?.nombre == 'Administrador';

  const AuthState({
    this.usuario,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    Usuario? usuario,
    String? token,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      usuario: usuario ?? this.usuario,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
//  Notifier de autenticacion
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  /// Intenta restaurar la sesion desde SharedPreferences.
  ///
  /// Se llama al iniciar la app. Si existe un token guardado,
  /// lo valida consultando GET /auth/me.
  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userJson = prefs.getString(AppConstants.userKey);

    if (token == null || userJson == null) {
      state = const AuthState();
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      // Validar que el token aun sea valido consultando el perfil
      final usuario = await _authService.getProfile();
      state = AuthState(usuario: usuario, token: token);
    } catch (_) {
      // Token invalido o expirado: limpiar sesion
      await _clearStorage();
      state = const AuthState();
    }
  }

  /// Inicia sesion con [username] y [password].
  ///
  /// En caso de exito, persiste el token y los datos del usuario
  /// en SharedPreferences para restaurar la sesion posteriormente.
  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authResponse = await _authService.login(username, password);
      await _saveSession(authResponse);
      state = AuthState(
        usuario: authResponse.usuario,
        token: authResponse.accessToken,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Registra un nuevo usuario y automaticamente inicia sesion.
  Future<void> register(
    String username,
    String password,
    String nombreCompleto,
    String email,
    int rolId,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.register(
        username,
        password,
        nombreCompleto,
        email,
        rolId,
      );
      // Registrar no retorna token; iniciamos sesion automaticamente
      await login(username, password);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cierra la sesion: limpia almacenamiento local y estado.
  Future<void> logout() async {
    await _clearStorage();
    state = const AuthState();
  }

  /// Obtiene la lista de roles disponibles.
  Future<List<Rol>> getRoles() => _authService.getRoles();

  // -----------------------------------------------------------------------
  //  Metodos auxiliares de persistencia
  // -----------------------------------------------------------------------

  /// Guarda el token y usuario en SharedPreferences.
  Future<void> _saveSession(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, authResponse.accessToken);
    await prefs.setString(
      AppConstants.userKey,
      jsonEncode(authResponse.usuario.toJson()),
    );
  }

  /// Elimina el token y usuario de SharedPreferences.
  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }
}

// ---------------------------------------------------------------------------
//  Providers
// ---------------------------------------------------------------------------

/// Provider del servicio de autenticacion (Dio inyectado).
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioProvider));
});

/// Provider del estado de autenticacion (StateNotifier).
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
